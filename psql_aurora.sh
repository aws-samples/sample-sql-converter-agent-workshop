#!/usr/bin/env bash
# Aurora PostgreSQL に psql で接続します。
#
# 接続情報（ホスト、ポート、ユーザー、パスワード）は、AWS Secrets Manager の
# シークレット aurora-pg-credentials から取得します。パスワードはコマンドラインの
# 引数には出さず、環境変数 PGPASSWORD で psql に渡します。接続は TLS（sslmode=require）です。
#
# 使い方:
#   ./psql_aurora.sh                          # 対話モードで接続
#   ./psql_aurora.sh -c 'SELECT version();'   # SQLを1つ実行して終了
#   ./psql_aurora.sh -f ./result/<オブジェクト名>/postgres.sql
#
# 引数は、そのまま psql に渡されます。
set -euo pipefail

SECRET_ID="aurora-pg-credentials"
DATABASE="${PGDATABASE:-postgres}"

if ! command -v psql >/dev/null 2>&1; then
    echo "エラー: psql が見つかりません。'sudo dnf install -y postgresql17' でインストールしてください。" >&2
    exit 1
fi

if ! secret_json="$(aws secretsmanager get-secret-value \
        --secret-id "$SECRET_ID" --query SecretString --output text)"; then
    echo "エラー: Secrets Manager からシークレット $SECRET_ID を取得できませんでした。" >&2
    exit 1
fi

{
    IFS= read -r PGHOST
    IFS= read -r PGPORT
    IFS= read -r PGUSER
    IFS= read -r PGPASSWORD
} < <(printf '%s' "$secret_json" | python3 -c '
import json, sys
s = json.load(sys.stdin)
print(s["host"])
print(s.get("port", 5432))
print(s["username"])
print(s["password"])
')
unset secret_json

export PGHOST PGPORT PGUSER PGPASSWORD
export PGDATABASE="$DATABASE"
export PGSSLMODE=require

exec psql "$@"
