# Oracle on EC2 へのダンプファイルのロード方法


## dumpファイルを配置
このディレクトリ以下にあるdumpfileディレクトリに、Data Pumpで出力したダンプファイルを配置してください。
尚、以下の手順で実行されるスクリプトでは、ダンプファイルは、以下の命名規則で出力されていることを前提としています。

[スキーマ名(大文字)]_METADATAONLY.DMP


## Amazon Q で Oracle on EC2のIPアドレスを確認

```bash
cd load
q chat "../ora2pg-conv-w-strands/cdk で作成された Oracle on EC2のPublic IPアドレスとPrivate IPアドレスを教えてください。"

/quit
```

## Oracle on EC2 の　IPアドレスを設定する

```bashh
export ORACLE_IP=10.50.0.78
```

## スキーマ作成、ダンプファイルをOracle on EC2 インスタンスにコピーする
```bash
vi 1pre.sh ### 作成したいユーザー名を編集します。

./1pre.sh
```

## Oracle Databaseにインポートする
```bash
vi 2load.sh ### impdpのオプションなど、適宜編集してください。

./2load.sh

```

# NOTE

以下のエラーが出る場合は、Oracle on EC2 インスタンスにて、以下のパスになるようにディレクトリを作成し、ダンプファイルを移動してください。

ORA-31640: unable to open dump file "/home/oracle/dumpfile/3E0A3xxxxxE003yyyyyyyy0C/TESTUSER_METADATAONLY.DMP" for read

