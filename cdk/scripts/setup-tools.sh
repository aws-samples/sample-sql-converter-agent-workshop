#!/bin/bash
set -e

echo "=== ツールセットアップ開始 ==="

# 必要なツールのインストール
echo "必要なツールをインストール中..."
dnf install -y git

# ワークショップリポジトリのクローン
# 第1引数のブランチ（deploy.sh を実行したブランチ）を clone する。
# 指定がない、名前が不正、または GitHub にない場合は、既定のブランチ（main）を clone する。
REPO_URL="https://github.com/aws-samples/sample-sql-converter-agent-workshop.git"
BRANCH="${1:-}"
if [[ -n "$BRANCH" && ! "$BRANCH" =~ ^[A-Za-z0-9._/-]+$ ]]; then
    echo "ブランチ名が不正なため、既定のブランチを使います: $BRANCH"
    BRANCH=""
fi
if [[ -n "$BRANCH" ]] && ! git ls-remote --exit-code --heads "$REPO_URL" "$BRANCH" >/dev/null 2>&1; then
    echo "ブランチ $BRANCH が GitHub にないため、既定のブランチを使います"
    BRANCH=""
fi
echo "ワークショップリポジトリをクローン中...（ブランチ: ${BRANCH:-既定}）"
if [[ -n "$BRANCH" ]]; then
    sudo -u ec2-user git clone -b "$BRANCH" "$REPO_URL" /home/ec2-user/sample-sql-converter-agent-workshop || true
else
    sudo -u ec2-user git clone "$REPO_URL" /home/ec2-user/sample-sql-converter-agent-workshop || true
fi

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

# opengrep のインストール（アプリケーションのソースから SQL の位置を見つける静的解析。
# エージェントのツール detect_sql_by_opengrep が使う）。taint の結果の形式に依存するため、バージョンを固定する。
OPENGREP_VERSION="v1.33.1"
echo "opengrep ${OPENGREP_VERSION} をインストール中..."
sudo -u ec2-user bash -c "curl -fsSL https://raw.githubusercontent.com/opengrep/opengrep/${OPENGREP_VERSION}/install.sh | bash -s -- -v ${OPENGREP_VERSION}" \
    || echo "警告: opengrep をインストールできませんでした（エージェントは opengrep なしで動作します）"

# エージェントの MCP ツールが使う Python のパッケージを、先に入れておく。
# 入れておかないと、参加者が最初にエージェントを起動したときに uv run が取得するため、
# MCP サーバの起動が遅れたり、時間切れになったりする（tree-sitter など、合わせて数十 MB）。
echo "MCP ツールの Python パッケージをインストール中..."
sudo -u ec2-user bash -c 'cd /home/ec2-user/sample-sql-converter-agent-workshop && ~/.local/bin/uv sync --project ./agent --frozen' \
    || echo "警告: Python パッケージを事前にインストールできませんでした（初回のエージェント起動時に取得します）"

echo "=== ツールセットアップ完了 ==="
