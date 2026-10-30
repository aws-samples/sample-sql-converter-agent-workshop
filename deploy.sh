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
cdk bootstrap
if ! cdk deploy --outputs-file ../output.json --require-approval never; then
    echo "エラー: CDK デプロイに失敗しました"
    exit 1
fi

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
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/HostName .*/HostName $NEW_INSTANCE_ID/" ssh-config
    else
        sed -i "s/HostName .*/HostName $NEW_INSTANCE_ID/" ssh-config
    fi
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

# ツールセットアップ（Kiro CLI, uv, AWS CLIリージョン設定）
echo "ツール（Kiro CLI, uv, git）のセットアップを開始します..."

# ツールセットアップ済みかチェック（Kiro CLIの存在で判定）
echo "ツール（Kiro CLI, uv, git）のインストール状態を確認しています..."
export CHECK_TOOLS_COMMAND_ID=$(aws ssm send-command \
  --instance-ids $ORACLE_INSTANCE_ID \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["if sudo -u ec2-user command -v kiro-cli >/dev/null 2>&1; then echo TOOLS_INSTALLED; else echo TOOLS_NOT_INSTALLED; fi"]' \
  --output text \
  --query "Command.CommandId")

# チェック結果を待機
sleep 10
export TOOLS_CHECK_RESULT=$(aws ssm get-command-invocation \
  --command-id "$CHECK_TOOLS_COMMAND_ID" \
  --instance-id "$ORACLE_INSTANCE_ID" \
  --query "StandardOutputContent" \
  --output text | tr -d '\n')

if [[ "$TOOLS_CHECK_RESULT" == "TOOLS_INSTALLED" ]]; then
    echo "ツール（Kiro CLI, uv, git）は既にインストール済みです。セットアップをスキップします。"
    TOOLS_INSTALL_SKIPPED=true
else
    echo "ツール（Kiro CLI, uv, git）がインストールされていません。セットアップを開始します..."
    TOOLS_INSTALL_SKIPPED=false

export TOOLS_COMMAND_ID=$(aws ssm send-command \
  --instance-ids $ORACLE_INSTANCE_ID \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["aws s3 cp s3://'$SCRIPT_BUCKET_NAME'/scripts/setup-tools.sh /tmp/setup-tools.sh && chmod +x /tmp/setup-tools.sh && /tmp/setup-tools.sh > /opt/oracle-install/tools-setup.log 2>&1"]' \
  --output text \
  --query "Command.CommandId")

if [ -z "$TOOLS_COMMAND_ID" ]; then
  echo "エラー: ツールセットアップコマンドの実行に失敗しました"
  exit 1
fi

echo "ツール（Kiro CLI, uv, git）セットアップのコマンド ID: $TOOLS_COMMAND_ID が発行されました"
echo "ツール（Kiro CLI, uv, git）セットアップの実行状態を監視します..."

while true; do
  export TOOLS_STATUS=$(aws ssm list-commands \
    --command-id "$TOOLS_COMMAND_ID" \
    --query "Commands[0].Status" \
    --output text)
  
  echo "$(date '+%Y-%m-%d %H:%M:%S') - ツール（Kiro CLI, uv, git）セットアップ状態: $TOOLS_STATUS"
  
  if [[ "$TOOLS_STATUS" = "Success" ]]; then
    echo "ツール（Kiro CLI, uv, git）のセットアップが正常に完了しました！"
    break
  elif [[ "$TOOLS_STATUS" = "Failed" || "$TOOLS_STATUS" = "Cancelled" || "$TOOLS_STATUS" = "TimedOut" ]]; then
    echo "ツール（Kiro CLI, uv, git）のセットアップが失敗しました。ステータス: $TOOLS_STATUS"
    
    echo "エラーの詳細を取得しています..."
    aws ssm get-command-invocation \
      --command-id "$TOOLS_COMMAND_ID" \
      --instance-id "$ORACLE_INSTANCE_ID" \
      --query "StandardErrorContent" \
      --output text
    
    exit 1
  fi
  sleep 30
done

# ツールセットアップ成功時の出力を表示
echo "ツール（Kiro CLI, uv, git）セットアップの出力:"
aws ssm get-command-invocation \
  --command-id "$TOOLS_COMMAND_ID" \
  --instance-id "$ORACLE_INSTANCE_ID" \
  --query "StandardOutputContent" \
  --output text
fi

# インスタンスを再起動（新規インストール時のみ）
if [[ "$ORACLE_INSTALL_SKIPPED" == "false" || "$TOOLS_INSTALL_SKIPPED" == "false" ]]; then
    echo "新規インストールが実行されたため、インスタンスを再起動します..."
    aws ec2 reboot-instances --instance-ids $ORACLE_INSTANCE_ID
    echo "インスタンスの再起動を開始しました。"
else
    echo "既存のインストールが検出されたため、再起動をスキップします。"
fi
echo ""
echo "デプロイが完了しました！"
