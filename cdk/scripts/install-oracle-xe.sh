function retry_command {
   local retries=5
   local wait_time=60
   local command="$1"
   local count=0
   until bash -c "$command"; do
   exit_code=$?
   count=$((count + 1))
   if [ $count -lt $retries ]; then
   echo "コマンド「$command」失敗。${wait_time}秒後に再試行します... ($count/$retries)"
   sleep $wait_time
   else
   echo "コマンド「$command」失敗。最大試行回数に達しました。"
   return $exit_code
   fi
   done
   return 0
}

echo --------------------------------------------------
echo DNFキャッシュのクリーンアップと更新
retry_command "dnf clean all"
retry_command "dnf makecache"

echo --------------------------------------------------
echo 必要なパッケージのインストール
retry_command "dnf install -y libnsl bc binutils ksh libaio openssl-libs perl"

echo --------------------------------------------------
echo redhat release の設置
cd /opt/oracle-install/
mv ./redhat-release /etc/redhat-release

echo --------------------------------------------------
echo package and dmp file download
aws s3 cp $1 /opt/oracle-install/ --recursive

echo --------------------------------------------------
echo Oracle Database XE 21c の前提条件パッケージの準備
# retry_command "wget https://yum.oracle.com/repo/OracleLinux/OL8/appstream/x86_64/getPackage/oracle-database-preinstall-21c-1.0-1.el8.x86_64.rpm"
retry_command "rpm -ivh --nodeps oracle-database-preinstall-21c-1.0-1.el8.x86_64.rpm"

echo --------------------------------------------------
echo Oracle Database XE 21c のダウンロードとインストール
# retry_command "wget https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm"
retry_command "dnf -y localinstall --skip-broken oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm"

echo --------------------------------------------------
echo Perl のシンボリックリンク作成
if [ -f /opt/oracle/product/21c/dbhomeXE/perl/bin/perl ]; then
  mv /opt/oracle/product/21c/dbhomeXE/perl/bin/perl /opt/oracle/product/21c/dbhomeXE/perl/bin/perl.orig
  ln -s /usr/bin/perl /opt/oracle/product/21c/dbhomeXE/perl/bin/perl
else
  echo "Perlバイナリが見つかりません。インストールに問題がある可能性があります。"
  exit 1
fi

echo --------------------------------------------------
echo データベースの構成
export ORACLE_PASSWORD=$(aws secretsmanager get-secret-value --secret-id oracle-credentials --query SecretString --output text | jq -r .password)
retry_command "/etc/init.d/oracle-xe-21c configure -skipOrdim"

echo --------------------------------------------------
echo Oracle ユーザーの環境設定
yes | cp -f ./.bash_profile /home/oracle/.bash_profile
chown oracle:oinstall /home/oracle/.bash_profile

echo --------------------------------------------------
echo listener.ora の設定
cp /opt/oracle/homes/OraDBHome21cXE/network/admin/listener.ora /opt/oracle/homes/OraDBHome21cXE/network/admin/listener.ora.bk
yes | cp ./listener.ora /opt/oracle/homes/OraDBHome21cXE/network/admin/listener.ora -f

echo --------------------------------------------------
echo tnsnames.ora の設定
ipv4=$(ec2-metadata | grep "public-ipv4" | awk '{print $2}')
cp /opt/oracle/homes/OraDBHome21cXE/network/admin/tnsnames.ora /opt/oracle/homes/OraDBHome21cXE/network/admin/tnsnames.ora.bk
yes | cp ./tnsnames.ora /opt/oracle/homes/OraDBHome21cXE/network/admin/tnsnames.ora -f
sed -i "s/your_ec2_public_ip/$ipv4/g" /opt/oracle/homes/OraDBHome21cXE/network/admin/tnsnames.ora

echo --------------------------------------------------
echo systemd サービスの設定
cat > /etc/systemd/system/oracle-xe-21c.service << EOF
[Unit]
Description=Oracle Database XE 21c Service
After=network.target

[Service]
Type=forking
RemainAfterExit=yes
ExecStart=/etc/init.d/oracle-xe-21c start
ExecStop=/etc/init.d/oracle-xe-21c stop
User=root

[Install]
WantedBy=multi-user.target
EOF

echo --------------------------------------------------
echo systemd 再起動
systemctl daemon-reload
systemctl enable oracle-xe-21c
retry_command "systemctl start oracle-xe-21c"

echo --------------------------------------------------
echo "Oracle XE CDBの起動を待機中..."
for i in {1..30}; do
    if su - oracle -c "sqlplus -s / as sysdba <<< 'SELECT 1 FROM DUAL;'" > /dev/null 2>&1; then
        echo "Oracle XE CDBが正常に起動しました"
        break
    fi
    echo "CDB起動待機中... ($i/30)"
    sleep 30
    if [ $i -eq 30 ]; then
        echo "Oracle XE CDBの起動がタイムアウトしました"
        exit 1
    fi
done

echo --------------------------------------------------
echo "PDB XEPDB1の起動を確認中..."
for i in {1..20}; do
    if su - oracle -c "sqlplus -s / as sysdba <<< 'ALTER PLUGGABLE DATABASE XEPDB1 OPEN;'" > /dev/null 2>&1; then
        echo "PDB XEPDB1が正常に起動しました"
        break
    fi
    echo "PDB起動待機中... ($i/20)"
    sleep 30
    if [ $i -eq 20 ]; then
        echo "PDB XEPDB1の起動がタイムアウトしました"
        exit 1
    fi
done

echo --------------------------------------------------
echo "データベース設定を実行中..."
su - oracle -c "sqlplus / as sysdba @/opt/oracle-install/setup.sql"

echo --------------------------------------------------
echo "リスナーを再起動します"
su - oracle -c "lsnrctl stop"
sleep 10
su - oracle -c "lsnrctl start"
sleep 60

echo --------------------------------------------------
echo "リスナー状態を確認します"
su - oracle -c "lsnrctl status"

echo --------------------------------------------------
echo "Oracle Database XE 21c のインストールが完了しました"

echo --------------------------------------------------
echo "datapump でスキーマ情報を取り込みます"
chown oracle:oinstall /opt/oracle-install/*.dmp 2>/dev/null || echo "No .dmp files found"
# dmpファイルを/opt/oracle-installから/home/oracleに移動
if ls /opt/oracle-install/*.dmp 1> /dev/null 2>&1; then
    mv /opt/oracle-install/*.dmp /home/oracle/
    chown oracle:oinstall /home/oracle/*.dmp
fi

# XEPDB1への接続確認
echo --------------------------------------------------
echo "XEPDB1への接続確認"
for i in {1..10}; do
    if su - oracle -c "sqlplus -s system/${ORACLE_PASSWORD}@localhost/XEPDB1 <<< 'SELECT 1 FROM DUAL;'" > /dev/null 2>&1; then
        echo "XEPDB1への接続が確認できました"
        break
    fi
    echo "XEPDB1接続待機中... ($i/10)"
    sleep 30
    if [ $i -eq 10 ]; then
        echo "XEPDB1への接続がタイムアウトしました"
        exit 1
    fi
done

# 各dmpファイルに対してインポートを実行
if [ -z "$dump_files" ]; then
    echo "Info: No dump files found in /home/oracle - skipping import"
else
    for dump_file in $dump_files; do
        import_schema "$dump_file"
    done
fi

echo --------------------------------------------------
echo "DB オブジェクトを作成します"
su - oracle -c "cd /opt/oracle-install/schema_sample && bash setup.sh"

echo --------------------------------------------------
echo "インストール完了"