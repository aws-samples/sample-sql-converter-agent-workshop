#!/bin/bash

# 実行方法:
# cd agent
# ./getDDL.sh <OBJECT_TYPE> <SCHEMA_NAME.OBJECT_NAME> [ORACLE_USER] [ORACLE_PASSWORD]
# 例: ./getDDL.sh PROCEDURE MYSCHEMA.MY_PROCEDURE
# 例: ./getDDL.sh PROCEDURE MYSCHEMA.MY_PROCEDURE username password

# 引数チェック
if [ $# -lt 2 ] || [ $# -gt 4 ]; then
    echo "Usage: $0 <OBJECT_TYPE> <SCHEMA_NAME.OBJECT_NAME> [ORACLE_USER] [ORACLE_PASSWORD]"
    echo "Example: $0 PROCEDURE MYSCHEMA.MY_PROCEDURE"
    echo "Example: $0 PROCEDURE MYSCHEMA.MY_PROCEDURE username password"
    exit 1
fi

OBJECT_TYPE=$1
FULL_OBJECT_NAME=$2
SCHEMA_NAME=$(echo $FULL_OBJECT_NAME | cut -d'.' -f1)
OBJECT_NAME=$(echo $FULL_OBJECT_NAME | cut -d'.' -f2)

# 認証情報の取得
if [ $# -eq 4 ]; then
    # 引数で認証情報が提供された場合
    ORACLE_USER=$3
    ORACLE_PASSWORD=$4
    echo "認証情報を引数から取得しました"
else
    # 引数で認証情報が提供されなかった場合、AWS Secrets Managerから取得
    echo "AWS Secrets Manager から認証情報を取得中..."
    SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id oracle-credentials --query SecretString --output text)

    if [ $? -ne 0 ]; then
        echo "エラー: AWS Secrets Manager からの認証情報取得に失敗しました"
        exit 1
    fi

    # JSONから認証情報を抽出
    ORACLE_USER=$(echo $SECRET_JSON | jq -r '.username')
    ORACLE_PASSWORD=$(echo $SECRET_JSON | jq -r '.password')
fi

# ローカルでresultディレクトリ作成
mkdir -p "./result/${OBJECT_NAME}"

# SSH経由でDDL取得し、直接ローカルファイルに出力
ssh -n -F ./../ssh-config -i ./../cdk/oracle-xe-key.pem oracle "sudo su - oracle -c \"
sqlplus -s ${ORACLE_USER}/${ORACLE_PASSWORD}@//localhost:1521/XEPDB1 <<SQL_EOF
SET PAGESIZE 0
SET LINESIZE 1000
SET LONG 10000
SELECT DBMS_METADATA.GET_DDL('${OBJECT_TYPE}', '${OBJECT_NAME}', '${SCHEMA_NAME}') FROM DUAL;
EXIT;
SQL_EOF
\"" > "./result/${OBJECT_NAME}/oracle.sql"

if [ $? -eq 0 ]; then
    echo "✓ DDL saved to ./result/${OBJECT_NAME}/oracle.sql"
else
    echo "✗ DDL取得に失敗しました"
    exit 1
fi
