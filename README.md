# Oracle to PostgreSQL Migration with Strands AI Agent

このプロジェクトは、AI エージェントを用いて、異種 DB 間で SQL を変換するワークショップです。  
題材として Oracle Database から Amazon Aurora PostgreSQL への SQL 変換を行います。  
AWS CDK を使用して OracleXE on EC2 と Aurora PostgreSQL のデータベースを構築し、SCT では変換できない Database Object と SQL 実行機能を有する Java アプリケーションを対象に [Strands Agents SDK](https://strandsagents.com/) を活用してデータベース分析と移行作業を軽減します。

> [!NOTE]
> このコンテンツは OracleDB と PostgreSQL を立て、この環境に閉じて AI エージェントが SQL を読み書きし、実行し、修正し、結果を残していくものです。
>  AI エージェントがシェルコマンドを実行したり、Database を操作する都合上、本番環境でのご利用はおやめください。あくまで、ここでコードを作成・テストするだけにとどめてください。また AI エージェントを動かす環境も EC2 等の使い捨てできる隔離環境を用意し、そこから実行してください。

## 🏗️ アーキテクチャ概要

- **Oracle Database**: EC2 インスタンス上の Oracle XE 21c
- **PostgreSQL**: Amazon Aurora PostgreSQL Serverless v2
- **AI Agent**: AI Agent w/Strands Agents によるデータベース分析・移行支援
- **Infrastructure**: AWS CDK (TypeScript)による Infrastructure as Code

## 📋 前提条件

### 必要なソフトウェア

- Python 3.12 以上
- Node.js 18 以上
- AWS CLI v2
- AWS CDK v2
- uv (Python package manager)

### AWS 環境

- AWS アカウントとプロファイル設定
- 適切な IAM 権限（EC2, RDS, Secrets Manager, S3, SSM 等）
- デフォルトリージョン: us-east-1(使用する Bedrock のモデル)

## 🚀 セットアップ手順

### 0. 前提条件のセットアップ

Workshop 環境では、以下の手順を実行して CDK や uv をインストールしてください。

```bash
# CDK のインストール
npm install -g aws-cdk

# uv のインストール
pip install uv
```

### 1. CDK 依存関係のインストール

```bash
git clone https://github.com/aws-samples/sample-sql-converter-agent-workshop.git
cd sample-sql-converter-agent-workshop

# CDK依存関係のインストール
npm ci --prefix cdk && npm --prefix cdk run cdk bootstrap
```

### 2. 必要ファイルの準備

**⚠️ 重要: 以下のファイルはユーザーが事前に用意する必要があります**

#### Oracle Database RPM ファイル

`cdk/dmp/` ディレクトリに以下の RPM ファイルをインターネットからダウンロードして配置してください：

- `oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm` - Oracle XE 21c 本体
- `oracle-database-preinstall-21c-1.0-1.el8.x86_64.rpm` - Oracle 前提パッケージ

e.g.

```shell
mkdir -p cdk/dmp && \
wget -P cdk/dmp \
  https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm \
  https://yum.oracle.com/repo/OracleLinux/OL8/appstream/x86_64/getPackage/oracle-database-preinstall-21c-1.0-1.el8.x86_64.rpm
```


### 3. インフラストラクチャのデプロイ

ルートディレクトリに移動した上で、以下コマンドを実行してください。

```bash
# デプロイスクリプトの実行
./deploy.sh
```

このスクリプトは以下の処理を自動実行します：

1. AWS CDK によるインフラストラクチャのデプロイ
2. EC2 キーペアの取得と SSH 設定
3. Oracle XE の自動インストール

### 4. 接続確認

Oracle Instance に接続します。
`./output.json` に記載されている `OracleInstanceId` の値をコピーし、 `ssh-config` の `<instance id>` の箇所に貼り付けてください。

`./ssh-config`
```
Host oracle
  HostName i-xxxxxxxxxxxxxxxxx
  User ec2-user
  IdentityFile ./cdk/oracle-xe-key.pem
  ProxyCommand aws ec2-instance-connect open-tunnel --instance-id %h --max-tunnel-duration 3600
  LocalForward 11521 localhost:1521
```

別タブで新しいターミナルを開き、`ssh -F ssh-config oracle` を実行して接続できることを確認してください。

デプロイ完了後、以下のコマンドで接続テストを実行できます。
データベースにクエリを投げられるようになるまで、少し時間がかかる場合があるので、エラーが発生した場合はリトライしてみてください。

```bash
# Oracle Database接続テスト
uv run ora_connect_test.py

# PostgreSQL接続テスト
uv run pg_connect_test.py
```

## (Option) データベースオブジェクトのロード

以下の手順に従って、データベースオブジェクトをアップロードしてください。
1. `./import-schema/dumpfile` に `{name}_METADATAONLY.DMP` をアップロードしてください。
2. `import-schema` フォルダ配下の各シェルスクリプトについて、コメントの指示に従い、スキーマ名でループしている箇所に、アップロードしたファイルのスキーマ名を列挙してください。
3. `import-schema` フォルダ配下のシェルスクリプトを番号順に実行してください。

```bash
chmod +x import-schema/1pre.sh
./import-schema/1pre.sh
chmod +x import-schema/2load.sh
./import-schema/2load.sh
```

`2load.sh` で以下のエラーが出る場合は、Oracle on EC2 インスタンスに oracle ユーザーでログインし、パスが一致するようにディレクトリを作成し、ダンプファイルを移動してください。

ORA-31640: unable to open dump file "/home/oracle/dumpfile/3E0A3xxxxxE003yyyyyyyy0C/TESTUSER_METADATAONLY.DMP" for read

ログイン手順
```bash
ssh -F ssh-config oracle
sudo su - oracle
```

## 🤖 AI エージェントを使用したデータベースコードオブジェクトの変換

### 4. エージェントの起動

```bash
cd ./agent/ # リポジトリルートディレクトリがカレントディレクトリの前提です

# 使い方 1 ）チャットで指示する場合
uv run main.py

# 使い方 2 ) DB Object を指定する場合
# DB_ONJECT_TYPE[space]SCHEMA_NAME.OBJECT_NAME で指定してください
uv run main.py --prompt "PROCEDURE SCHEMA_SAMPLE.SCT_0001_CALCULATE_TIME_DIFFERENCE"

# 使い方 3 ) まとめて実行する場合
./run.sh

# run.sh のオプション一覧
# --system-prompt <ファイル名>: カスタムシステムプロンプトファイルを指定
# -f, --file <ファイル名>: 処理対象のオブジェクトリストファイルを指定（デフォルト: object_list.ini）
# --avoid-throttling: Bedrockのトークン制限エラー時に自動リトライを有効化

# 使用例:
./run.sh --system-prompt custom_prompt.txt
./run.sh -f custom_object_list.ini
./run.sh --avoid-throttling
./run.sh --system-prompt custom_prompt.txt --file custom_list.ini --avoid-throttling

# 全てのオブジェクトを一括処理する場合:
./run.sh -f object_list_all.ini --avoid-throttling

```

### 5. カスタム利用例
コードの行数が長い場合や複雑なプロシージャの場合に、変換順序の調整やコードを分割してから変換することが有効であるため、その実行方法をみていきます。
ポート11521が既に使用されているといったエラーが発生する場合、別ウィンドウでの実施中のSSHポート転送を終了してください

```bash
cd ./agent/ # リポジトリルートディレクトリがカレントディレクトリの前提です

# OracleのDDLをまとめて取得 
./getDDL.sh object_list.ini

#並び替え
uv run main.py --system-prompt sortObject.txt
  (起動後に以下を貼り付けてください。)
  ./result

  prompts/sortObject.txtに従って処理を実行してください。

# 変換実行
./run.sh --system-prompt custom_prompt.txt --file object_list_sorted.ini

```


## 🤖 AI エージェントを使用したアプリケーションSQLの変換
サンプルとしてOracleデータベースを使用した従業員情報の管理（登録、更新、削除、検索）を行うSpring + MyBatisアプリケーションの基盤となるスクリプト群を変換します。

### 6. サンプルアプリケーションの確認
リポジトリルートディレクトリにある `./application/` に配置されたサンプルアプリケーションの内容をチェックしてください。


### 7. エージェントの起動

```bash
cd ../agent # リポジトリルートディレクトリがカレントディレクトリの前提です

# アプリケーションの変換
# 例) uv run main.py --prompt "<ソースの配置場所> <アプリ名> <テスト名>" --system-prompt "system_prompt_app.txt"
uv run main.py --prompt "../application/employee-mgmt/application employee-mgmt test01" --system-prompt "system_prompt_app.txt"

```


## その他

### Amazon Q Developer のセットアップ方法

インストール方法
https://docs.aws.amazon.com/ja_jp/amazonq/latest/qdeveloper-ug/command-line-installing-ssh-setup-autocomplete.html#command-line-install-q

セットアップ方法（認証設定から「CLI」タブを選択）
https://catalog.workshops.aws/qwords/ja-JP/10-start-workshop/16-builder-id


###　Oracle Database への接続方法

```bash
# Oracle XE on EC2 インスタンスへの接続 
cd sample-sql-converter-agent-workshop/
ssh -F ssh-config oracle

# Oracle ユーザーに遷移
sudo su - oracle

# Oracle Database の SYSおよびSYSTEMスキーマのパスワードを取得
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id oracle-credentials --region us-east-1 --query SecretString --output text)
DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')

# Oracle Database に接続
sqlplus sys/${DB_PASSWORD}@localhost/XEPDB1 as sysdba

sqlplus system/${DB_PASSWORD}@localhost/XEPDB1 

```


