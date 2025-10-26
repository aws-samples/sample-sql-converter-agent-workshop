#!/bin/bash

# Oracle DDL一括取得スクリプト
# 使用方法: ./batch_getDDL.sh [object_list_file]
# デフォルトファイル: object_list.ini

# 入力ファイルの設定（引数があれば使用、なければデフォルト）
FILE=${1:-object_list.ini}

# ファイル存在チェック
[ ! -f "$FILE" ] && { echo "エラー: $FILE が見つかりません"; exit 1; }

echo "=== DDL一括取得開始 (ファイル: $FILE) ==="

# AWS Secrets Managerから認証情報を取得
SECRET=$(aws secretsmanager get-secret-value --secret-id oracle-credentials --query SecretString --output text)
[ $? -ne 0 ] && { echo "エラー: 認証情報取得に失敗"; exit 1; }

# JSON解析でユーザー名とパスワードを抽出
USER=$(echo $SECRET | jq -r '.username')
PASS=$(echo $SECRET | jq -r '.password')

# オブジェクトリストを1行ずつ処理
while read -r line; do
    # コメント行と空行をスキップ
    [[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]] && continue
    
    # オブジェクトタイプと名前を分割
    TYPE=$(echo "$line" | awk '{print $1}')
    NAME=$(echo "$line" | awk '{print $2}')
    
    # 必須項目チェック
    [ -z "$TYPE" ] || [ -z "$NAME" ] && continue
    
    # スキーマ名とオブジェクト名を分離
    SCHEMA=$(echo $NAME | cut -d'.' -f1)
    OBJ=$(echo $NAME | cut -d'.' -f2)
    
    echo "処理中: $TYPE $NAME"
    
    # 出力ディレクトリ作成
    mkdir -p "./result/$OBJ"
    
    # SSH経由でOracleに接続してDDL取得
#    ssh -n -F ./../ssh-config -i ./../cdk/oracle-xe-key.pem oracle "sudo su - oracle -c \"
    ssh -n -i ./../cdk/oracle-xe-key.pem oracle "sudo su - oracle -c \"
sqlplus -s $USER/$PASS@//localhost:1521/XEPDB1 <<EOF
SET PAGESIZE 0
SET LINESIZE 1000
SET LONG 10000
SELECT DBMS_METADATA.GET_DDL('$TYPE', '$OBJ', '$SCHEMA') FROM DUAL;
EXIT;
EOF
\"" > "./result/$OBJ/oracle.sql"
    
    # 結果表示
    [ $? -eq 0 ] && echo "✓ 完了: $OBJ" || echo "✗ 失敗: $OBJ"
    
done < "$FILE"

echo "=== DDL一括取得完了 ==="
