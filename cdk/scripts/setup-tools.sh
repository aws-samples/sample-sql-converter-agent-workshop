#!/bin/bash
set -e

echo "=== ツールセットアップ開始 ==="

# 必要なツールのインストール
echo "必要なツールをインストール中..."
dnf install -y git

# ワークショップリポジトリのクローン
echo "ワークショップリポジトリをクローン中..."
sudo -u ec2-user git clone https://github.com/aws-samples/sample-sql-converter-agent-workshop.git /home/ec2-user/sample-sql-converter-agent-workshop || true

# Kiro CLI のインストール
echo "Kiro CLI をインストール中..."
sudo -u ec2-user bash -c 'curl -fsSL https://cli.kiro.dev/install | bash -s -- --force'
sudo -u ec2-user mkdir -p /home/ec2-user/.kiro/settings

# AWS CLI リージョン設定
echo "AWS CLI リージョンを設定中..."
sudo -u ec2-user bash -c '
# IMDSv2を使用してトークンを取得
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
    -s)

# リージョンを取得
REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
    -s http://169.254.169.254/latest/meta-data/placement/region)

# リージョンを設定
aws configure set region "$REGION"

echo "Region set to: $REGION"
'

# uv のインストール
echo "uv をインストール中..."
sudo -u ec2-user bash -c 'wget -qO- https://astral.sh/uv/install.sh | sh'

echo "=== ツールセットアップ完了 ==="
