# 入力ファイルの形式

親: [../SKILL.md](../SKILL.md)。

## 必要なファイル

| ファイル | 必須か | 用途 |
|---|---|---|
| detail.csv 相当 | あれば使う | Action Itemsの詳細。`parse_sct_csv`で対象のオブジェクトを特定する |
| summary.csv 相当 | あれば使う | Action Itemsの概要。同上 |
| converted.sql 相当 | あれば使う | SCT / DMS SCが変換したPostgreSQL。変換の出発点 |
| 元のOracleのDDL（例: `DDL_oracle.sql`） | 任意 | 変換前のOracleの定義。`oracle.sql`、Oracle側の実行テスト、差異の調査に使う |

出力がない場合は、Oracleから元の定義を取得して一から変換する（SKILL.md「DMS SC / SCTの出力がない場合」）。
出力の場所が示されていない場合は、探し回らずにユーザーに尋ねる（SKILL.md の手順0）。

## 2つの形式

| | AWS SCT単体のツール | AWS DMS Schema Conversion（DMS SC） |
|---|---|---|
| detail相当 | `detail.csv` | `<エンドポイント名>.csv` |
| summary相当 | `summary.csv` | `<エンドポイント名>_Action_Items_Summary.csv` |
| converted.sql相当 | `converted.sql` | `PostgreSQL-<日時>.sql`（同梱サンプルでは`DDL_converted.sql`） |
| 元のOracleのDDL | なし | `Oracle-<日時>.sql`（同梱サンプルでは`DDL_oracle.sql`） |
| 分割に使うツール | `parse_sct_converted_sql` | `parse_dms_sc_converted_sql` |

converted.sql相当のファイルに`-- ------------ Write ...-stage scripts -----------`という見出しがあれば
DMS SC形式、なければSCT単体形式と判定する。どちらの形式かをユーザーに尋ねる必要はない。

DMS SC形式では、変換できなかった箇所が`/* [<番号> - Severity <重大度> - <説明>] */`というコメントとして
オブジェクトの中に埋め込まれる。`parse_dms_sc_converted_sql`は、このコメントがあるオブジェクトを
`status: "action_items"`、ないオブジェクトを`status: "converted"`として返す。

## S3のパスを渡された場合

`s3://`で始まるパスを受け取ったら、`download_s3_input`で`input/db-object/assessment/`にダウンロードし、
返されたローカルのパスを使う。DMS SCの出力は3つのZIP（アセスメントのCSV、元のOracleのDDL、
変換後のPostgreSQL）に分かれており、ダウンロード時に展開される。
