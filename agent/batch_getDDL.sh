#!/bin/bash

# object_list.iniに記載されたオブジェクトに対してgetDDL.shを一括実行

OBJECT_LIST_FILE="object_list.ini"

# オプション解析
while [[ $# -gt 0 ]]; do
    case $1 in
        --file)
            OBJECT_LIST_FILE="$2"
            shift 2
            ;;
        *)
            echo "Usage: $0 [--file <object_list_file>]"
            exit 1
            ;;
    esac
done

if [ ! -f "$OBJECT_LIST_FILE" ]; then
    echo "エラー: $OBJECT_LIST_FILE が見つかりません"
    exit 1
fi

echo "=== DDL一括取得開始 (ファイル: $OBJECT_LIST_FILE) ==="

# AWS Secrets Managerから認証情報を一度だけ取得
echo "AWS Secrets Manager から認証情報を取得中..."
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id oracle-credentials --query SecretString --output text)

if [ $? -ne 0 ]; then
    echo "エラー: AWS Secrets Manager からの認証情報取得に失敗しました"
    exit 1
fi

# JSONから認証情報を抽出
ORACLE_USER=$(echo $SECRET_JSON | jq -r '.username')
ORACLE_PASSWORD=$(echo $SECRET_JSON | jq -r '.password')

echo "認証情報を取得しました。バッチ処理を開始します..."

# object_list.iniを読み込んで処理
while IFS= read -r line; do
    # コメント行と空行をスキップ
    if [[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]]; then
        continue
    fi
    
    # タブまたはスペースで分割
    OBJECT_TYPE=$(echo "$line" | awk '{print $1}')
    OBJECT_NAME=$(echo "$line" | awk '{print $2}')
    
    if [ -n "$OBJECT_TYPE" ] && [ -n "$OBJECT_NAME" ]; then
        echo "処理中: $OBJECT_TYPE $OBJECT_NAME"
        ./getDDL.sh "$OBJECT_TYPE" "$OBJECT_NAME" "$ORACLE_USER" "$ORACLE_PASSWORD"
        
        if [ $? -eq 0 ]; then
            echo "✓ 完了: $OBJECT_NAME"
        else
            echo "✗ 失敗: $OBJECT_NAME"
        fi
        echo "---"
    fi
done < "$OBJECT_LIST_FILE"

echo "=== DDL一括取得完了 ==="
