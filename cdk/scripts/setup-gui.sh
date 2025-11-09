#!/bin/bash
set -e

echo "=== Amazon Linux 2023 GUI環境セットアップ開始 ==="

# パッケージのアップデート
echo "パッケージをアップデート中..."
dnf update -y

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
geometry=1024x768
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
