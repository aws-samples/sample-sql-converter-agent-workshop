# SQL Converter Agent Workshop

SQL Converter Agent Workshop は、AI エージェントを用いて、異種 DB 間で SQL を変換するワークショップです。  
題材として Oracle Database から Amazon Aurora PostgreSQL への SQL 変換を行います。  
AWS CDK を使用して Oracle XE on EC2 と Aurora PostgreSQL のデータベースを構築し、SCT では変換できないデータベースオブジェクトと SQL 実行機能を有する Java アプリケーションを対象に [Strands Agents SDK](https://strandsagents.com/) 及び [Amazon Q Developer CLI](https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line.html) を活用して SQL 変換作業を軽減します。

> [!NOTE]
> このコンテンツは Oracle DB と PostgreSQL を立て、この環境に閉じて AI エージェントが SQL を読み書きし、実行し、修正し、結果を残していくものです。
> AI エージェントが Database を操作する都合上、本番環境でのご利用はおやめください。あくまで、ここでコードを生成・テストするだけにとどめてください。

## 🏗️ アーキテクチャ概要

- **Oracle Database**: EC2 インスタンス上の Oracle XE 21c
- **PostgreSQL**: Amazon Aurora PostgreSQL Serverless v2
- **AI エージェント**: Oracle DB を立てている EC2 に配置した Strands Agent 製 AI エージェントもしくは Amazon Q Developer
- **Amazon Bedrock**: Strands Agent 製 AI エージェントが使用するモデルを提供するサービス

![](./image/architecture.png)

## 📋 前提条件

### 必要な環境

- シェルスクリプトが動作する環境(Linux, Mac で動作確認)
- Node.js

他、必要なものはこのワークショップを実行時にインストールします。

### AWS 環境

- AdministratorAccess がアタッチされ、シェルスクリプトが実行可能なコンピューティングリソース
- Bedrock で利用するモデルは us-east-1 です(コードの修正で変更可能)
  - 事前に使用するモデルを unlock してください。デフォルトでは `us.anthropic.claude-sonnet-4-20250514-v1:0` を使用します。

## 🚀 セットアップ手順

### 0. 前提条件のセットアップ

以下の手順を実行して CDK や uv をインストールしてください。

```bash
# CDK のインストール
npm install -g aws-cdk

# uv のインストール
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 1. リポジトリのクローン
```bash
git clone https://github.com/aws-samples/sample-sql-converter-agent-workshop.git
cd sample-sql-converter-agent-workshop
```

### 2. CDK 依存関係のインストール

```bash
# CDK依存関係のインストール
# sample-sql-converter-agent-workshop ディレクトリで実行してください
npm ci --prefix cdk && npm --prefix cdk run cdk bootstrap
```

### 3. 必要ファイルの準備

**⚠️ 重要: 以下のファイルはユーザーが事前に用意する必要があります**

#### Oracle Database RPM ファイル

`sample-sql-converter-agent-workshop` の配下の `cdk/dmp/` ディレクトリに以下の RPM ファイルをインターネットからダウンロードして配置してください：

- `oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm` - Oracle XE 21c 本体
- `oracle-database-preinstall-21c-1.0-1.el8.x86_64.rpm` - Oracle 前提パッケージ

e.g.

```shell
mkdir -p cdk/dmp && \
wget -P cdk/dmp \
  https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm \
  https://yum.oracle.com/repo/OracleLinux/OL8/appstream/x86_64/getPackage/oracle-database-preinstall-21c-1.0-1.el8.x86_64.rpm
```


### 4. デプロイ

リポジトリのルートディレクトリに移動した上で、以下コマンドを実行してください。30 分ほど実行にかかります。

```bash
./deploy.sh
```

このスクリプトは以下の処理を自動実行します：

1. AWS CDK によるインフラストラクチャのデプロイ
2. EC2 キーペアの取得と SSH 設定
3. Oracle XE の自動インストール
4. エージェントを実行する環境準備

### 5. 接続確認

デプロイ完了後、`ssh -F ssh-config oracle` を実行して接続できることを確認してください。  
初回接続時は接続先の fingerprint が信頼できるかの確認が表示されます（yes/no/[fingerprint]）。`yes` と入力してください。  
接続先で以下のコマンドを実行しデータベースに接続できることを確認してください。  

```bash
cd sample-sql-converter-agent-workshop

# Oracle Database接続テスト
uv run ora_connect_test.py

# PostgreSQL接続テスト
uv run pg_connect_test.py
```

上記は Oracle DB がホストされている EC2 での実行ですが、`ssh -F ssh-config oracle` で接続した場合、
ポートフォワーディングによって、ローカルから実行することもできます。  
ssh 接続しているターミナルとは別にターミナルを開き、`sample-sql-converter-agent-workshop` ディレクトリから、以下を実行して確認することもできます。  
```bash
# Oracle Database接続テスト
uv run ora_connect_test.py

# PostgreSQL接続テスト
uv run pg_connect_test.py
```

## 🤖 AI エージェント(Strands Agents)を使用したデータベースコードオブジェクトの変換

### 1. エージェントの起動

`ssh -F ssh-config oracle` でつないだ先、もしくはつないでいる PC の別ターミナルで以下を実行します。  
以下操作は `sample-sql-converter-agent-workshop` ディレクトリにいることを前提とします。
エージェントの動作をカスタマイズしたい場合は事前に `agent/prompts/system_prompt.txt` を編集してください。

#### 1.1 チャットで指示する場合
以下コマンドを打つとユーザーの入力を待ち受けている状態になります。
```bash
cd ./agent/ 
uv run main.py
```

`あなたは何ができますか？` というプロンプトを打つとどんなことをできるのかを教えてくれる他、データベースオブジェクトを Oracle から検索して PostgreSQL のオブジェクトに変換を始めます(e.g.`PROCEDURE SCHEMA_SAMPLE.SCT_0001_CALCULATE_TIME_DIFFERENCE`)。  
格納されているオブジェクトリストは `object_list_all.ini` にあるので参考にしてください。  
結果は `./result/` 以下に出力されます。  
対話をやめたい場合は `quit` と入力すると終わります。  

#### 1.2 データベースオブジェクトを指定する場合
以下コマンドを打つと指定した Oracle DB に格納されているデータベースオブジェクトを自動で探して PostgreSQL のオブジェクトに変換します。  
格納されているオブジェクトリストは `object_list_all.ini` にあるので参考にしてください。  
チャット同様に結果は `./result/` 以下に出力されます。

```bash
cd ./agent/ 
uv run main.py --prompt "PROCEDURE SCHEMA_SAMPLE.SCT_0001_CALCULATE_TIME_DIFFERENCE"
```

#### 1.3 まとめて実行する場合

`./agent/object_list.ini` にあるデータベースオブジェクトを対象に一括変換を試みます。

```bash
cd ./agent/
./run.sh
```

#### 1.4 (Option) 呼出時に受付可能な引数
`run.sh` および `main.py` にはいくつかのオプション機能があります。

##### システムプロンプトのカスタマイズ
`run.sh` 及び `main.py` ではシステムプロンプトのカスタマイズを受け付けます。  
`--mode custom` を付加すると、`agent/prompts/custom/custom.txt` で記述するプロンプトが適用されます。  
`custom.txt` を編集して用途にあったプロンプトを設定してください。

```bash
uv run main.py --prompt "PROCEDURE SCHEMA_SAMPLE.SCT_0001_CALCULATE_TIME_DIFFERENCE" --mode "custom"
./run.sh --mode custom
```

##### DB Object のファイル指定
一括で変換をかける際、変換したい DB Object リストを `-f, --file <テキストファイル名>`の形で DB Object を改行で列挙したテキストファイルで渡すことができます。デフォルトでは `-f object_list.ini` が設定されています。

```bash
./run.sh -f custom_object_list.ini
```

##### エラー時のリトライ及び sleep 機能

`--avoid-throttling` オプションを使うことで Bedrock のトークン制限エラー時に自動リトライ及び token 使用量に応じた sleep を有効化できます。

```bash
uv run main.py --avoid-throttling
./run.sh --avoid-throttling
```

##### マルチエージェント変換モード

`--multi-agent` オプションを使うことで、3段階のマルチエージェント変換を実行できます。このモードでは以下の3つの専門エージェントが順次処理を行います：

1. **Oracle検証エージェント**: DDL取得、テストコード作成、Oracle上でのテスト実行
2. **PostgreSQL変換エージェント**: Oracle→PostgreSQL変換、構文チェック
3. **PostgreSQL検証エージェント**: テスト実行、結果比較、OK/NG判定

```bash
# 単一オブジェクトのマルチエージェント変換
uv run main.py --multi-agent --prompt "PROCEDURE SCHEMA_SAMPLE.SCT_0001_CALCULATE_TIME_DIFFERENCE"

# スロットリング対策付き
uv run main.py --multi-agent --avoid-throttling --prompt "PROCEDURE SCHEMA_SAMPLE.SCT_0001_CALCULATE_TIME_DIFFERENCE"

# バッチ処理（run.sh経由）
./run.sh --multi-agent
./run.sh --multi-agent --avoid-throttling
```

マルチエージェントのプロンプト設定は `agent/prompts/prompts.py` の `MultiAgent` クラスで管理されています。各段階のプロンプトファイルは `agent/prompts/db_object/multi_agent/` に配置されています。

## 🤖 AI エージェントを使用したアプリケーションSQLの変換
サンプルとしてOracleデータベースを使用した従業員情報の管理（登録、更新、削除、検索）を行うSpring + MyBatisアプリケーションの基盤となるスクリプト群を変換します。

### 1. サンプルアプリケーションの確認
リポジトリルートディレクトリにある `./application/` に配置されたサンプルアプリケーションの内容をチェックしてください。


### 2. エージェントの起動

以下操作は `sample-sql-converter-agent-workshop` ディレクトリにいることを前提とします。

```bash
cd ./agent # リポジトリルートディレクトリがカレントディレクトリの前提です

# アプリケーションの変換
# 例) uv run main.py --prompt "<ソースの配置場所> <アプリ名> <テスト名>" --mode "app"
uv run main.py --prompt "../application/employee-mgmt/application employee-mgmt test01" --mode "app"

```

## Amazon Q Developer CLI をコーディングエージェントとして使う場合
Oracle DB/PostgreSQLへのアクセスするツールはMCPサーバー化してあるため、Strands Agentsを使わずにAmazon Q Developer CLIから同様のことを行うこともできます。  
Amazon Q Developer CLIのインストール方法及びサブスクライブの方法については[install](https://docs.aws.amazon.com/ja_jp/amazonq/latest/qdeveloper-ug/command-line-installing.html),[subscribe](https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/q-admin-setup-subscribe-general.html)を参照してください。  
リモートサーバーの場合はインストール済のためサブスクライブだけで済みます。
sshで繋いでトンネリングしたローカル環境でAmazon Q Developer CLIを実行する場合は、`~/.aws/amazonq/` に `q-dev/mcp.json` をコピーしてください。リモートサーバーは設定済です。

### Q Developer の起動
以下コマンドを実行してください。

```bash
cd q-dev
q login
# q login 実行後、表示される指示に従う
q chat
# q chatを打ち込むと対話できるようになるため、データベースオブジェクトを入力することで変換作業を行うことができます。(e.g. PROCEDURE SCHEMA_SAMPLE.SCT_0001_CALCULATE_TIME_DIFFERENCE)
```

### Q Developer のカスタマイズ
`q-dev/AmazonQ.md` の指示を参照します。カスタマイズしたい場合は `AmazonQ.md` を編集するか、[こちら](https://docs.aws.amazon.com/ja_jp/amazonq/latest/qdeveloper-ug/command-line-context.html)を参照して、指示をカスタマイズしてください。


## 環境の削除
`./destroy.sh` を実行してください。  
`./destroy.sh` を実行する際、DMS を使用していた場合は DMS を使用した環境でスキーマ変換ウィザードを Close してから `./destroy.sh` を実行してください。Close しないとエラーが発生して削除ができません。