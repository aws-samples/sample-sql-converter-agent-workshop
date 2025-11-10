#!/bin/bash
set -e

echo "=== Amazon Linux 2023 GUI環境セットアップ開始 ==="

# パッケージのアップデート
echo "パッケージをアップデート中..."
dnf update -y

# 必要なツールのインストール
echo "必要なツールをインストール中..."
dnf install -y git

# GNOME デスクトップ環境のインストール
echo "GNOME デスクトップ環境をインストール中..."
dnf groupinstall "Desktop" -y

# TigerVNC サーバーのインストール
echo "TigerVNC サーバーをインストール中..."
dnf install -y tigervnc-server

# VNCパスワードの設定
echo "VNCパスワードを設定中..."
sudo -u ec2-user mkdir -p /home/ec2-user/.vnc
sudo -u ec2-user bash -c 'echo "rdppassword123" | vncpasswd -f > /home/ec2-user/.vnc/passwd'
sudo -u ec2-user chmod 600 /home/ec2-user/.vnc/passwd

# VNCサーバーユーザー設定
echo "VNCサーバーユーザー設定中..."
echo ":1=ec2-user" > /etc/tigervnc/vncserver.users

# VNCサーバー設定ファイルの作成
echo "VNCサーバー設定ファイルを作成中..."
cat > /etc/tigervnc/vncserver-config-defaults << 'EOF'
session=gnome
securitytypes=vncauth,tlsvnc
geometry=1440x900
localhost
alwaysshared
EOF

# VNCサーバーの起動
echo "VNCサーバーを起動中..."
systemctl start vncserver@:1

# VNCサーバーの自動起動設定
echo "VNCサーバーの自動起動を設定中..."
systemctl enable vncserver@:1

# アイドルロックスクリーンの無効化
echo "アイドルロックスクリーンを無効化中..."
sudo -u ec2-user bash -c 'DISPLAY=:1 gsettings set org.gnome.desktop.session idle-delay 0' || true

# ワークショップリポジトリのクローン
echo "ワークショップリポジトリをクローン中..."
sudo -u ec2-user git clone https://github.com/aws-samples/sample-sql-converter-agent-workshop.git /home/ec2-user/sample-sql-converter-agent-workshop || true

# Amazon Q Developer CLI のインストール
echo "Amazon Q Developer CLI をインストール中..."
sudo -u ec2-user curl --proto '=https' --tlsv1.2 -sSf "https://desktop-release.q.us-east-1.amazonaws.com/latest/q-x86_64-linux.zip" -o "/home/ec2-user/q.zip"
sudo -u ec2-user unzip /home/ec2-user/q.zip -d /home/ec2-user/
sudo -u ec2-user Q_SKIP_SETUP=1 /home/ec2-user/q/install.sh
sudo -u ec2-user mkdir -p /home/ec2-user/.aws/amazonq/
sudo -u ec2-user cp /home/ec2-user/sample-sql-converter-agent-workshop/agent/mcp.json /home/ec2-user/.aws/amazonq/

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
sudo -u ec2-user bash -c 'wget -qO- https://astral.sh/uv/install.sh | sh'


echo "=== GUI環境セットアップ完了 ==="
echo "接続情報:"
echo ""
echo "【VNC接続】"
echo "  ポート: 5901"
echo "  パスワード: rdppassword123"
echo "  対応クライアント:"
echo "    - macOS Screen Sharing: vnc://localhost:5901"
echo "    - RealVNC Viewer: localhost:5901"
echo "    - その他VNCクライアント"
echo ""
echo "SSH トンネリング:"
echo "  ssh -F ssh-config -L 5901:localhost:5901 oracle"
