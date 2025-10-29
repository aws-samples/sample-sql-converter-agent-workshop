#!/bin/bash

set -e

# AWS Secrets Managerからパスワード取得
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id oracle-credentials --region us-east-1 --query SecretString --output text)
export DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')

# スキーマ名を定義
# for TARGET in xxxxx xxxxx ... のように dumpfile 配下にある {name}_METADATAONLY.DMP の数だけ追記
# (デフォルトではダミーの TESTUSER と記述されているのでアップデートしてください)
for TARGET in TESTUSER
do
  echo ${TARGET}
# SSH経由でOracleインスタンスに接続し、ダンプファイルロード処理を実行
  ssh -tt -F ssh-config oracle << EOF

sudo su - oracle << ORACLE_EOF

impdp system/${DB_PASSWORD}@localhost/XEPDB1 \
  DIRECTORY=DATA_PUMP_DIR \
  DUMPFILE=${TARGET}_METADATAONLY.DMP \
  LOGFILE=imp_${TARGET}.log \
  SCHEMAS=${TARGET} \
  remap_tablespace=DATA_${TARGET}:USERS \
  TABLE_EXISTS_ACTION=REPLACE

sqlplus -s system/${DB_PASSWORD}@localhost/XEPDB1 << SQL_EOF

BEGIN
  DBMS_UTILITY.COMPILE_SCHEMA('${TARGET}');
END;
/

SQL_EOF

ORACLE_EOF
exit

EOF
done

echo "処理が完了しました。"

