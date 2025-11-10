#!/bin/bash

# AWS CLI ページャーを無効化
export AWS_PAGER=""

stack_name="SqlConverterAgentStack"

# DMS VPC Role の管理
echo "DMS VPC Role の設定を確認しています..."

# dms-vpc-role が存在するかチェック
if aws iam get-role --role-name dms-vpc-role >/dev/null 2>&1; then
    echo "dms-vpc-role が存在します。ポリシーの確認中..."
    
    # AmazonDMSVPCManagementRole ポリシーがアタッチされているかチェック
    if aws iam list-attached-role-policies --role-name dms-vpc-role --query 'AttachedPolicies[?PolicyName==`AmazonDMSVPCManagementRole`]' --output text | grep -q AmazonDMSVPCManagementRole; then
        echo "dms-vpc-role に AmazonDMSVPCManagementRole が既にアタッチされています。"
    else
        echo "dms-vpc-role に AmazonDMSVPCManagementRole をアタッチしています..."
        aws iam attach-role-policy --role-name dms-vpc-role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole
        echo "ポリシーのアタッチが完了しました。"
    fi
else
    echo "dms-vpc-role が存在しません。作成しています..."
    
    # Trust Policy の作成
    cat > /tmp/dms-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "dms.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
    
    # ロールの作成
    aws iam create-role --role-name dms-vpc-role --assume-role-policy-document file:///tmp/dms-trust-policy.json --description "Role for DMS VPC management"
    
    # ポリシーのアタッチ
    aws iam attach-role-policy --role-name dms-vpc-role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole
    
    # 一時ファイルの削除
    rm -f /tmp/dms-trust-policy.json
    
    echo "dms-vpc-role の作成とポリシーのアタッチが完了しました。"
fi

cd cdk
cdk deploy --outputs-file ../output.json --require-approval never

# oracle-xe-key.pem ファイルが存在するか確認し、存在する場合は削除
if [ -f ../oracle-xe-key.pem ]; then
    echo "既存の oracle-xe-key.pem ファイルを削除します..."
    rm -f ../oracle-xe-key.pem
fi

# output.json からコマンドを抽出して実行
echo "AWS SSMからキーペアを取得しています..."
export COMMAND=$(jq -r --arg stack_name "${stack_name}" '.[$stack_name].OracleKeyPairRetrievalCommand' ../output.json)

echo "実行するコマンド: $COMMAND"
eval "$COMMAND"

cd ../agent/
[ -L oracle-xe-key.pem ] && unlink oracle-xe-key.pem
ln -s ../oracle-xe-key.pem oracle-xe-key.pem
cd ../

# ssh-config の HostName を新しいインスタンスIDで更新
export NEW_INSTANCE_ID=$(jq -r --arg stack_name "${stack_name}" '.[$stack_name].OracleInstanceId' output.json)
if [ -f ssh-config ] && [ ! -z "$NEW_INSTANCE_ID" ]; then
    sed -i '' "s/HostName .*/HostName $NEW_INSTANCE_ID/" ssh-config
    echo "ssh-config を新しいインスタンスID ($NEW_INSTANCE_ID) で更新しました。"
fi

cd cdk/

# 確認 - macOS用にstat命令を修正
if [ -f ../oracle-xe-key.pem ]; then
    # macOSとLinuxで異なるstat構文に対応
    if [[ "$(uname)" == "Darwin" ]]; then
        PERMS=$(stat -f '%A' ../oracle-xe-key.pem)
    else
        PERMS=$(stat -c '%a' ../oracle-xe-key.pem)
    fi
    echo "キーペアの取得に成功しました。権限は $PERMS に設定されています。"
    echo "以下のコマンドでEC2インスタンスに接続できます:"
    echo "$(jq -r --arg stack_name "${stack_name}" '.[$stack_name].SSHCommand' ../output.json)"
else
    echo "キーペアの取得に失敗しました。"
fi

echo "asset を s3 にコピーしています。"
export SCRIPT_BUCKET_NAME=$(jq -r --arg stack_name "${stack_name}" '.[$stack_name].ScriptBucketName' ../output.json)

# S3にRPMファイルが既に存在するかチェック
echo "S3バケット内のRPMファイル存在確認中..."
if aws s3 ls s3://$SCRIPT_BUCKET_NAME/dmp/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm >/dev/null 2>&1; then
    echo "RPMファイルは既にS3に存在します。コピーをスキップします。"
else
    echo "RPMファイルをS3にコピーします..."
    aws s3 cp ./dmp/ s3://$SCRIPT_BUCKET_NAME/dmp --recursive
fi

# スクリプトファイルをS3にコピー
echo "スクリプトファイルをS3にコピーします..."
aws s3 cp ./scripts/ s3://$SCRIPT_BUCKET_NAME/scripts --recursive


export ORACLE_INSTANCE_ID=$(jq -r --arg stack_name "${stack_name}" '.[$stack_name].OracleInstanceId' ../output.json)

echo "Oracle インスタンス ID: $ORACLE_INSTANCE_ID"

# Oracle XE がインストール済みかチェック
echo "Oracle XE のインストール状態を確認しています..."
export CHECK_ORACLE_COMMAND_ID=$(aws ssm send-command \
  --instance-ids $ORACLE_INSTANCE_ID \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["if systemctl is-active oracle-xe-21c >/dev/null 2>&1; then echo ORACLE_INSTALLED; else echo ORACLE_NOT_INSTALLED; fi"]' \
  --output text \
  --query "Command.CommandId")

# チェック結果を待機
sleep 10
export ORACLE_CHECK_RESULT=$(aws ssm get-command-invocation \
  --command-id "$CHECK_ORACLE_COMMAND_ID" \
  --instance-id "$ORACLE_INSTANCE_ID" \
  --query "StandardOutputContent" \
  --output text | tr -d '\n')

if [[ "$ORACLE_CHECK_RESULT" == "ORACLE_INSTALLED" ]]; then
    echo "Oracle XE は既にインストール済みです。インストールをスキップします。"
    ORACLE_INSTALL_SKIPPED=true
else
    echo "Oracle XE がインストールされていません。インストールを開始します..."
    ORACLE_INSTALL_SKIPPED=false

echo "Oracle インスタンス ID: $ORACLE_INSTANCE_ID でコマンド実行を開始します..."

export COMMAND_ID=$(aws ssm send-command \
  --instance-ids $ORACLE_INSTANCE_ID \
  --document-name "AWS-RunShellScript" \
  --parameters commands="/opt/oracle-install/install-oracle-xe.sh s3://$SCRIPT_BUCKET_NAME/dmp/ > /opt/oracle-install/install.log" \
  --output text \
  --query "Command.CommandId")

if [ -z "$COMMAND_ID" ]; then
  echo "エラー: コマンドの実行に失敗しました"
  exit 1
fi

echo "コマンド ID: $COMMAND_ID が発行されました"
echo "コマンドの実行状態を監視します..."

while true; do
  export STATUS=$(aws ssm list-commands \
    --command-id "$COMMAND_ID" \
    --query "Commands[0].Status" \
    --output text)
  
  echo "$(date '+%Y-%m-%d %H:%M:%S') - 現在の状態: $STATUS"
  
  if [[ "$STATUS" = "Success" ]]; then
    echo "コマンドが正常に完了しました！"
    break
  elif [[ "$STATUS" = "Failed" || "$STATUS" = "Cancelled" || "$STATUS" = "TimedOut" ]]; then
    echo "コマンドが失敗しました。ステータス: $STATUS"
    
    echo "エラーの詳細を取得しています..."
    aws ssm get-command-invocation \
      --command-id "$COMMAND_ID" \
      --instance-id "$ORACLE_INSTANCE_ID" \
      --query "StandardErrorContent" \
      --output text
    
    exit 1
  fi
  sleep 60
done

# 成功した場合は出力を表示
if [[ "$ORACLE_INSTALL_SKIPPED" == "false" ]]; then
    echo "Oracle XE インストール出力:"
    aws ssm get-command-invocation \
      --command-id "$COMMAND_ID" \
      --instance-id "$ORACLE_INSTANCE_ID" \
      --query "StandardOutputContent" \
      --output text
fi

echo "Oracle XEのインストールが完了しました"
fi

# GUI環境のセットアップ
echo "GUI環境のセットアップを開始します..."

# GUI環境がインストール済みかチェック
echo "GUI環境のインストール状態を確認しています..."
export CHECK_GUI_COMMAND_ID=$(aws ssm send-command \
  --instance-ids $ORACLE_INSTANCE_ID \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["if systemctl is-active vncserver@:1 >/dev/null 2>&1; then echo GUI_INSTALLED; else echo GUI_NOT_INSTALLED; fi"]' \
  --output text \
  --query "Command.CommandId")

# チェック結果を待機
sleep 10
export GUI_CHECK_RESULT=$(aws ssm get-command-invocation \
  --command-id "$CHECK_GUI_COMMAND_ID" \
  --instance-id "$ORACLE_INSTANCE_ID" \
  --query "StandardOutputContent" \
  --output text | tr -d '\n')

if [[ "$GUI_CHECK_RESULT" == "GUI_INSTALLED" ]]; then
    echo "GUI環境は既にインストール済みです。セットアップをスキップします。"
    GUI_INSTALL_SKIPPED=true
else
    echo "GUI環境がインストールされていません。セットアップを開始します..."
    GUI_INSTALL_SKIPPED=false

export GUI_COMMAND_ID=$(aws ssm send-command \
  --instance-ids $ORACLE_INSTANCE_ID \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["aws s3 cp s3://'$SCRIPT_BUCKET_NAME'/scripts/setup-gui.sh /tmp/setup-gui.sh && chmod +x /tmp/setup-gui.sh && /tmp/setup-gui.sh > /opt/oracle-install/gui-setup.log 2>&1"]' \
  --output text \
  --query "Command.CommandId")

if [ -z "$GUI_COMMAND_ID" ]; then
  echo "エラー: GUI セットアップコマンドの実行に失敗しました"
  exit 1
fi

echo "GUI セットアップコマンド ID: $GUI_COMMAND_ID が発行されました"
echo "GUI セットアップの実行状態を監視します..."

while true; do
  export GUI_STATUS=$(aws ssm list-commands \
    --command-id "$GUI_COMMAND_ID" \
    --query "Commands[0].Status" \
    --output text)
  
  echo "$(date '+%Y-%m-%d %H:%M:%S') - GUI セットアップ状態: $GUI_STATUS"
  
  if [[ "$GUI_STATUS" = "Success" ]]; then
    echo "GUI セットアップが正常に完了しました！"
    break
  elif [[ "$GUI_STATUS" = "Failed" || "$GUI_STATUS" = "Cancelled" || "$GUI_STATUS" = "TimedOut" ]]; then
    echo "GUI セットアップが失敗しました。ステータス: $GUI_STATUS"
    
    echo "エラーの詳細を取得しています..."
    aws ssm get-command-invocation \
      --command-id "$GUI_COMMAND_ID" \
      --instance-id "$ORACLE_INSTANCE_ID" \
      --query "StandardErrorContent" \
      --output text
    
    exit 1
  fi
  sleep 30
done

# GUI セットアップ成功時の出力を表示
echo "GUI セットアップ出力:"
aws ssm get-command-invocation \
  --command-id "$GUI_COMMAND_ID" \
  --instance-id "$ORACLE_INSTANCE_ID" \
  --query "StandardOutputContent" \
  --output text
fi

# インスタンスを再起動（新規インストール時のみ）
if [[ "$ORACLE_INSTALL_SKIPPED" == "false" || "$GUI_INSTALL_SKIPPED" == "false" ]]; then
    echo "新規インストールが実行されたため、インスタンスを再起動します..."
    aws ec2 reboot-instances --instance-ids $ORACLE_INSTANCE_ID
    echo "インスタンスの再起動を開始しました。"
else
    echo "既存のインストールが検出されたため、再起動をスキップします。"
fi
echo "再起動完了後、以下の手順でVNCにアクセスできます:"
echo "1. SSH トンネリング: ssh -F ssh-config -L 5901:localhost:5901 oracle"
echo "2. VNC クライアントで localhost:5901 に接続"
echo "3. パスワード: rdppassword123"
echo ""
echo "デプロイが完了しました！"
