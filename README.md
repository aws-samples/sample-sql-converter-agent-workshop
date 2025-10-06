# Oracle to PostgreSQL Migration with Strands AI Agent

このプロジェクトは、Oracle Database から Amazon Aurora PostgreSQL へのデータベース移行を支援するサンプル AI エージェントシステムです。  
AWS CDK を使用して OracleXE on EC2 と Aurora PostgreSQL のデータベースを構築し、SCT では変換できない Database Object を対象に Strands Agents を活用してデータベース分析と移行作業を軽減します。

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
- デフォルトリージョン: us-east-1

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
wget https://dnh3ofuyfknm.cloudfront.net/public/workshop-ora2pg/ora2pg-conv-w-strands.zip
unzip ora2pg-conv-w-strands.zip
cd ora2pg-conv-w-strands

# CDK依存関係のインストール
cd cdk
npm install
cdk bootstrap
```

### 2. 必要ファイルの準備

**⚠️ 重要: 以下のファイルはユーザーが事前に用意する必要があります**

#### Oracle Database RPM ファイル

`cdk/dmp/` ディレクトリに以下の RPM ファイルをインターネットからダウンロードして配置してください：

- `oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm` - Oracle XE 21c 本体
- `oracle-database-preinstall-21c-1.0-1.el8.x86_64.rpm` - Oracle 前提パッケージ

e.g.

```shell
mkdir dmp
cd dmp
wget https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm
wget https://yum.oracle.com/repo/OracleLinux/OL8/appstream/x86_64/getPackage/oracle-database-preinstall-21c-1.0-1.el8.x86_64.rpm
```

ダウンロード完了後、`cdk/dmp/` ディレクトリに配置してください：

```
cdk/dmp/
├── oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm
└── oracle-database-preinstall-21c-1.0-1.el8.x86_64.rpm
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

#### 参考: デプロイスクリプトがエラーとなる場合
過去にDMSを使用したことがある場合、DMSの利用を開始するために必要なリソース作成の操作が重複することで、以下のようなエラーが出る場合があります。

```bash
Resource handler returned message: "Service role name AWSServiceRoleForDMSServerless has been taken in this ac
count, please try a different suffix.
```

このエラーが出た場合は、 `cdk/bin/cdk.ts` において、`initializeDmsSc = false` と設定して再度デプロイスクリプトを実行してください。

`cdk/bin/cdk.ts`

```typescript
new Ora2pgStack(app, 'Ora2pgStack', {
  initializeDmsSc: false,  // ここを false に変更
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION,
  },
});
```

### 4. 接続確認

Oracle Instance に接続します。
`cdk/output.json` に記載されている `OracleInstanceId` の値をコピーし、 `ssh-config` の `<instance id>` の箇所に貼り付けてください。

`ssh-config`
```
Host oracle
  HostName <instance id>
  User ec2-user
  IdentityFile ./cdk/oracle-xe-key.pem
  ProxyCommand aws ec2-instance-connect open-tunnel --instance-id %h --max-tunnel-duration 3600
  LocalForward 11521 localhost:1521
```

ローカルやEC2等、ワークショップ以外の環境で設定する場合は、`./cdk/oracle-xe-key.pem` を `~/.ssh/` にコピーした上で、`~/.ssh/config` に以下の設定を追加してください。

`~/.ssh/config`

```
Host oracle
  HostName <InstanceId>
  User ec2-user
  IdentityFile ~/.ssh/oracle-xe-key.pem
  ProxyCommand aws ec2-instance-connect open-tunnel --instance-id %h --max-tunnel-duration 3600
  LocalForward 11521 localhost:1521
```

これにより、`ssh oracle` を実行すれば、AWS の認証情報を用いて EC2 Instance Connect Endpoint を経由して EC2 インスタンスに ssh で接続できるようになります。
また、ssh で接続されている間は、Port Forwarding でローカル環境の 11521 番ポートが、EC2 インスタンスの 1521 番ポートに Forward されるようになります。

別タブで新しいターミナルを開き、`ssh -F ssh-config oracle` を実行して接続できることを確認してください。


デプロイ完了後、以下のコマンドで接続テストを実行できます

```bash
# Oracle Database接続テスト
uv run ora_connect_test.py

# PostgreSQL接続テスト
uv run pg_connect_test.py
```

## (Option) データベースオブジェクトのロード

以下の手順に従って、データベースオブジェクトをアップロードしてください。
1. `./load-scripts/dumpfile` に `{name}_METADATAONLY.DMP` をアップロードしてください。
2. `load-scripts` フォルダ配下の各シェルスクリプトについて、コメントの指示に従い、スキーマ名でループしている箇所に、アップロードしたファイルのスキーマ名を列挙してください。
3. `load-scripts` フォルダ配下のシェルスクリプトを番号順に実行してください。権限不足でエラーが出る場合には `chmod +x load-scripts/1pre.sh` のように権限付与してください。

`2load.sh` で以下のエラーが出る場合は、Oracle on EC2 インスタンスに oracle ユーザーでログインし、パスが一致するようにディレクトリを作成し、ダンプファイルを移動してください。

ORA-31640: unable to open dump file "/home/oracle/dumpfile/3E0A3xxxxxE003yyyyyyyy0C/TESTUSER_METADATAONLY.DMP" for read

ログイン手順
```bash
ssh -F ssh-config oracle
sudo su - oracle
```

## 🤖 AI エージェントの使用

### 4. エージェントの起動

```bash
cd agent

# 使い方 1 ）チャットで指示する場合
uv run main.py

# 使い方 2 ) DB Object を指定する場合
# DB_ONJECT_TYPE[space]SCHEMA_NAME.OBJECT_NAME で指定してください
# 特にオプション指定がない場合は、system_prompt.txt を参照します
uv run main.py --prompt "PROCEDURE SCHEMA_SAMPLE.SCT_0001_CALCULATE_TIME_DIFFERENCE" --system-prompt custom_prompt.txt

# 使い方 3 ) まとめて実行する場合
# 特にオプション指定がない場合は、system_prompt.txt およびobject_list.ini を参照します
./run.sh --system-prompt custom_prompt.txt --file custom_list.ini

```

### 5. カスタム利用例 (変換順序の調整、および分割戦略を取る場合)

```bash
cd agent

# OracleのDDLをまとめて取得
./batch_getDDL.sh --file object_list.ini

#並び替え
q chat "custom_prompt_1sortObject.txtに従って処理を実行してください。"

# 変換実行
./run.sh --system-prompt custom_prompt_2convert.txt --file object_list_sorted.ini

```
