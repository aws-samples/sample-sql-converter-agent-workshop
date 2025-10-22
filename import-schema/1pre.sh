#!/bin/bash

set -e

# Oracle IPアドレスを環境変数から取得
# if [ -z "$ORACLE_IP" ]; then
#   echo "Error: ORACLE_IP environment variable is not set"
#   exit 1
# fi

# Oracle DatabaseのパスワードをSecret Manager から取得
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id oracle-credentials --region us-east-1 --query SecretString --output text)
export DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')

# Oracleスキーマの作成
# for TARGET in xxxxx xxxxx ... のように dumpfile 配下にある {name}_METADATAONLY.DMP の数だけ追記
# (デフォルトではダミーの TESTUSER と記述されているのでアップデートしてください)
for TARGET in TESTUSER
do

TARGET_S=$TARGET
TARGET=`echo $TARGET | tr [a-z] [A-Z]`

ssh -tt -F ssh-config oracle << EOF

# Oracleユーザーに遷移
sudo su - oracle << ORACLE_EOF

sqlplus -s system/${DB_PASSWORD}@localhost/XEPDB1 << SQL_EOF

drop user $TARGET_S cascade;

create user $TARGET_S identified by ${DB_PASSWORD} ;

grant dba to $TARGET_S ;

SQL_EOF

ORACLE_EOF

exit

EOF

done

# ローカルのダンプファイルをOracle on EC2 インスタンスの/tmpにコピー
scp -F ssh-config ./load/dumpfile/*.DMP oracle:/tmp/.

# Oracle on EC2 インスタンスにダンプファイル用ディレクトリを作成
ssh -tt -F ssh-config oracle << EOF

# Oracleユーザーに遷移
sudo su - oracle << ORACLE_EOF

# ダンプファイル用ディレクトリ作成
mkdir -p dumpfile

cp /tmp/*.DMP dumpfile/

# Oracle Data Pumpで使用するディレクトリオブジェクトを作成
sqlplus -s system/${DB_PASSWORD}@localhost/XE << SQL_EOF

CREATE OR REPLACE DIRECTORY DATA_PUMP_DIR AS '/home/oracle/dumpfile';

SQL_EOF

ORACLE_EOF

exit

EOF

echo "準備が完了しました。"
