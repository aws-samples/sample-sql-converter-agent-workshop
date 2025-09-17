# Oracle to PostgreSQL Migration with Strands AI Agent

このプロジェクトは、Oracle Database から Amazon Aurora PostgreSQLへのデータベース移行を支援するサンプル AI エージェントシステムです。  
AWS CDKを使用して OracleXE on EC2 と Aurora PostgreSQL のデータベースを構築し、SCT では変換できない Database Object を対象に Strands Agents を活用してデータベース分析と移行作業を軽減します。

## 🏗️ アーキテクチャ概要

- **Oracle Database**: EC2インスタンス上のOracle XE 21c
- **PostgreSQL**: Amazon Aurora PostgreSQL Serverless v2
- **AI Agent**: AI Agent w/Strands Agentsによるデータベース分析・移行支援
- **Infrastructure**: AWS CDK (TypeScript)による Infrastructure as Code

## 📋 前提条件

### 必要なソフトウェア
- Python 3.12以上
- Node.js 18以上
- AWS CLI v2
- AWS CDK v2
- uv (Python package manager)

### AWS環境
- AWS アカウントとプロファイル設定
- 適切なIAM権限（EC2, RDS, Secrets Manager, S3, SSM等）
- デフォルトリージョン: us-east-1

## 🚀 セットアップ手順

### 1. リポジトリのクローンと依存関係のインストール

```bash
# mwinit で認証
mwinit --aea
# clone
git clone git@ssh.gitlab.aws.dev:gokazu/ora2pg-conv-w-strands.git
cd ora2pg-conv-w-strands

# CDK依存関係のインストール
cd cdk
npm install
cd ..
```

### 2. 必要ファイルの準備

**⚠️ 重要: 以下のファイルはユーザーが事前に用意する必要があります**

#### Oracle Database RPMファイル
`cdk/dmp/` ディレクトリに以下のRPMファイルをインターネットからダウンロードして配置してください：

- `oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm` - Oracle XE 21c本体
- `oracle-database-preinstall-21c-1.0-1.el8.x86_64.rpm` - Oracle前提パッケージ

e.g. 
```shell
wget https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm
wget https://yum.oracle.com/repo/OracleLinux/OL8/latest/x86_64/getPackage/oracle-database-preinstall-21c-1.0-1.el8.x86_64.rpm
```

ダウンロード完了後、`cdk/dmp/` ディレクトリに配置してください：

```
cdk/dmp/
├── oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm
└── oracle-database-preinstall-21c-1.0-1.el8.x86_64.rpm
```

### 3. インフラストラクチャのデプロイ

```bash
# デプロイスクリプトの実行
./deploy.sh
```

このスクリプトは以下の処理を自動実行します：
1. AWS CDKによるインフラストラクチャのデプロイ
2. EC2キーペアの取得とSSH設定
3. Oracle XEの自動インストール
4. データベース接続テストの実行

### 4. 接続確認

デプロイ完了後、以下のコマンドで接続テストを実行できます(`3. インフラストラクチャのデプロイ`にも含みますが、失敗したときは再実行すると上手くいくことがあります)：

```bash
# Oracle Database接続テスト
uv run ora_connect_test.py

# PostgreSQL接続テスト
uv run pg_connect_test.py
```

## 🤖 AIエージェントの使用

### 4. エージェントの起動

```bash
cd agent

# 使い方 1 ）チャットで指示する場合
uv run main.py 

# 使い方 2 ) DB Object を指定する場合
uv run main.py --prompt "PROCEDURE SCHEMA_SAMPLE.SCT_0001_CALCULATE_TIME_DIFFERENCE" # DB_ONJECT_TYPE[space]SCHEMA_NAME.OBJECT_NAME で指定

# 使い方 3 ) まとめて実行する場合
./run.sh # object_list.ini を見て実行
```