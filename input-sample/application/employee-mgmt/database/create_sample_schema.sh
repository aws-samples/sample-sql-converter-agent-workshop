#!/usr/bin/env bash
# サンプルアプリケーション（employee-mgmt）の表、シーケンス、索引、トリガーとデータを、
# Oracle Database の SCHEMA_SAMPLE スキーマと、Aurora PostgreSQL の schema_sample スキーマに作成します。
#
# - Oracle 側は schema_oracle.sql を、SCHEMA_SAMPLE ユーザーで実行します
#   （接続情報は AWS Secrets Manager のシークレット oracle-credentials-schema-sample）。
# - PostgreSQL 側は、変換済みの schema_postgre.sql を、search_path を schema_sample にして実行します
#   （接続はリポジトリの psql_aurora.sh を使います）。
# - 両方に同じデータ（部署 60 件、社員 50 件）を入れます。
# - 何度実行しても同じ状態になります（既存の表とシーケンスは削除してから作り直します）。
#
# 使い方（SQL Converter Agent サーバの ec2-user で、リポジトリのディレクトリから）:
#   ./input-sample/application/employee-mgmt/database/create_sample_schema.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

ORACLE_SECRET_ID="oracle-credentials-schema-sample"
ORACLE_DSN="//localhost:1521/XEPDB1"
PG_SCHEMA="schema_sample"

export ORACLE_HOME="${ORACLE_HOME:-/opt/oracle/product/21c/dbhomeXE}"
export PATH="$ORACLE_HOME/bin:$PATH"
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8

if ! command -v sqlplus >/dev/null 2>&1; then
    echo "エラー: sqlplus が見つかりません（ORACLE_HOME=$ORACLE_HOME）。" >&2
    exit 1
fi

echo "== Oracle Database: SCHEMA_SAMPLE に作成します"
secret_json="$(aws secretsmanager get-secret-value \
    --secret-id "$ORACLE_SECRET_ID" --query SecretString --output text)"
ORA_USER="$(printf '%s' "$secret_json" | python3 -c 'import json,sys; print(json.load(sys.stdin)["username"])')"
ORA_PASSWORD="$(printf '%s' "$secret_json" | python3 -c 'import json,sys; print(json.load(sys.stdin)["password"])')"
unset secret_json

# パスワードをコマンドラインの引数に出さないよう、接続は標準入力から渡します。
sqlplus -S /nolog <<EOF
WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE
SET FEEDBACK OFF
CONNECT ${ORA_USER}/"${ORA_PASSWORD}"@${ORACLE_DSN}
@${SCRIPT_DIR}/schema_oracle.sql
EOF

sqlplus -S /nolog <<EOF
WHENEVER SQLERROR EXIT FAILURE
SET FEEDBACK OFF PAGESIZE 50 TAB OFF
CONNECT ${ORA_USER}/"${ORA_PASSWORD}"@${ORACLE_DSN}
COLUMN table_name FORMAT A12
SELECT 'departments' AS table_name, COUNT(*) AS row_count FROM departments
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'job_history', COUNT(*) FROM job_history;
EXIT
EOF
unset ORA_PASSWORD

echo
echo "== Aurora PostgreSQL: ${PG_SCHEMA} に作成します"
cd "$REPO_ROOT"
PGOPTIONS="-c client_min_messages=warning" \
    ./psql_aurora.sh -q -v ON_ERROR_STOP=1 -c "CREATE SCHEMA IF NOT EXISTS ${PG_SCHEMA};"
PGOPTIONS="-c search_path=${PG_SCHEMA} -c client_min_messages=warning" \
    ./psql_aurora.sh -q -v ON_ERROR_STOP=1 -f "$SCRIPT_DIR/schema_postgre.sql"
PGOPTIONS="-c search_path=${PG_SCHEMA}" ./psql_aurora.sh -v ON_ERROR_STOP=1 -c "
SELECT 'departments' AS table_name, COUNT(*) AS row_count FROM departments
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'job_history', COUNT(*) FROM job_history;"

echo "完了しました。"
