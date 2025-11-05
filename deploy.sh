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
cdk deploy --outputs-file output.json --require-approval never

# oracle-xe-key.pem ファイルが存在するか確認し、存在する場合は削除
if [ -f oracle-xe-key.pem ]; then
    echo "既存の oracle-xe-key.pem ファイルを削除します..."
    rm -f oracle-xe-key.pem
fi

# output.json からコマンドを抽出して実行
echo "AWS SSMからキーペアを取得しています..."
export COMMAND=$(jq -r --arg stack_name "${stack_name}" '.[$stack_name].OracleKeyPairRetrievalCommand' output.json)

echo "実行するコマンド: $COMMAND"
eval "$COMMAND"

# 確認 - macOS用にstat命令を修正
if [ -f oracle-xe-key.pem ]; then
    # macOSとLinuxで異なるstat構文に対応
    if [[ "$(uname)" == "Darwin" ]]; then
        PERMS=$(stat -f '%A' ../oracle-xe-key.pem)
    else
        PERMS=$(stat -c '%a' ../oracle-xe-key.pem)
    fi
    cd agent/
    ln -s ../oracle-xe-key.pem oracle-xe-key.pem
    cd ../
    echo "キーペアの取得に成功しました。権限は $PERMS に設定されています。"
    echo "以下のコマンドでEC2インスタンスに接続できます:"
    echo "$(jq -r --arg stack_name "${stack_name}" '.[$stack_name].SSHCommand' output.json)"
else
    echo "キーペアの取得に失敗しました。"
fi

echo "AWS SSMからキーペアを取得しています..."
export SCRIPT_BUCKET_NAME=$(jq -r --arg stack_name "${stack_name}" '.[$stack_name].ScriptBucketName' output.json)
aws s3 cp ./dmp/ s3://$SCRIPT_BUCKET_NAME/dmp --recursive


export ORACLE_INSTANCE_ID=$(jq -r --arg stack_name "${stack_name}" '.[$stack_name].OracleInstanceId' ./output.json)

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
echo "コマンド出力:"
aws ssm get-command-invocation \
  --command-id "$COMMAND_ID" \
  --instance-id "$ORACLE_INSTANCE_ID" \
  --query "StandardOutputContent" \
  --output text

echo "Oracle XEのインストールが完了しました"

echo --------------------------------------------------
echo "GUI環境のセットアップを開始します..."

export GUI_COMMAND_ID=$(aws ssm send-command \
  --instance-ids $ORACLE_INSTANCE_ID \
  --document-name "AWS-RunShellScript" \
  --parameters commands="/opt/oracle-install/setup-gui.sh > /opt/oracle-install/gui-setup.log 2>&1" \
  --output text \
  --query "Command.CommandId")

if [ -z "$GUI_COMMAND_ID" ]; then
  echo "エラー: GUI設定コマンドの実行に失敗しました"
  exit 1
fi

echo "GUI設定コマンド ID: $GUI_COMMAND_ID が発行されました"
echo "GUI設定の実行状態を監視します..."

while true; do
  export GUI_STATUS=$(aws ssm list-commands \
    --command-id "$GUI_COMMAND_ID" \
    --query "Commands[0].Status" \
    --output text)
  
  echo "$(date '+%Y-%m-%d %H:%M:%S') - GUI設定状態: $GUI_STATUS"
  
  if [[ "$GUI_STATUS" = "Success" ]]; then
    echo "GUI設定が正常に完了しました！"
    break
  elif [[ "$GUI_STATUS" = "Failed" || "$GUI_STATUS" = "Cancelled" || "$GUI_STATUS" = "TimedOut" ]]; then
    echo "GUI設定が失敗しました。ステータス: $GUI_STATUS"
    
    echo "エラーの詳細を取得しています..."
    aws ssm get-command-invocation \
      --command-id "$GUI_COMMAND_ID" \
      --instance-id "$ORACLE_INSTANCE_ID" \
      --query "StandardErrorContent" \
      --output text
    
    exit 1
  fi
  sleep 60
done

echo "GUI設定出力:"
aws ssm get-command-invocation \
  --command-id "$GUI_COMMAND_ID" \
  --instance-id "$ORACLE_INSTANCE_ID" \
  --query "StandardOutputContent" \
  --output text

echo --------------------------------------------------
echo "セットアップ完了！"
echo "EC2コンソールから以下の手順でGUIアクセスできます:"
echo "1. EC2コンソールでインスタンスを選択"
echo "2. 'Connect'ボタンをクリック"
echo "3. 'RDP client'タブを選択"
echo "4. 'Connect using Fleet Manager'をクリック"
