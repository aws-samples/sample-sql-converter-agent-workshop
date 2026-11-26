---
name: workflow-db-convert
description: AWS SCT / DMS Schema Conversionが変換しきれなかったOracleのDBオブジェクト（テーブル、ビュー、ファンクション、トリガー、プロシージャ、パッケージ）を、PostgreSQLに変換する手順。「SCTで変換できなかったオブジェクトを変換して」「converted.sqlのこのオブジェクトを変換して」「残りのオブジェクトも変換して」のような依頼のときに使う。
---

# DBオブジェクトの変換手順（db track）

SCT / DMS Schema Conversion（DMS SC）が一度変換した結果をもとに、残った部分をPostgreSQLに仕上げる。
入力ファイルの形式は[references/input-formats.md](./references/input-formats.md)、構文ごとの書き方は
`domain-conversion-rules`、出力の形式は`tool-output-layout`に従う。

## 手順（1件ずつ変換する）

0. **入力の場所を確かめる**: 依頼にDMS SC / SCTの出力の場所（`s3://`のパスやローカルのディレクトリ）が書かれておらず、
   同じ会話の中でもまだ示されていなければ、ファイルを探し回ったり、S3のバケット名を推測したりしない。次のように尋ねて、
   答えを待つ。
   > DMS Schema Conversion（またはSCT）の出力（評価レポートのCSVと、変換前後のSQL）はどこにありますか。
   > - S3に保存している場合は、そのS3のパス（`s3://...`）を教えてください。
   > - ローカルにある場合は、そのディレクトリを教えてください。
   > - 出力がない場合は、ソースのOracle Databaseから元の定義を直接取得して変換します。
   - S3のパスを受け取ったら`download_s3_input`で取り込む（references/input-formats.md「S3のパスを渡された場合」）。
     パスがフォルダ（`/`で終わる）なら、末尾に`*.zip`を付けて呼ぶ（フォルダの下には、DMS SCが内部で使うファイルも
     多数あるため）。日時の異なるZIPが複数ある場合は、どれを使うかを尋ねる。
   - 「出力がない」と答えられたら、下記「DMS SC / SCTの出力がない場合」に従う。
1. **対象を特定する**: `parse_sct_csv`でdetail / summaryのCSVを読み、対象のオブジェクトとAction Itemを確かめる。
   Action Itemの意味や推奨の対処がCSVの記載だけでは分からない場合は、`lookup_action_item`で番号から引く
   （DMS SCとSCTは同じ番号を使う）。
2. **変換後のコードを取り出す**: converted.sql相当のファイルから、`object_name`を指定して対象のブロックだけを取り出す
   （SCT単体形式は`parse_sct_converted_sql`、DMS SC形式は`parse_dms_sc_converted_sql`）。
   ブロックがない、または空やコメントだけの場合は、手順3で取得した元の定義から変換する。
3. **元のOracleの定義を取得する**: 下記「元のOracle定義の取得」の順で取得する。
4. **決定的なルールで置き換える**: `convert_oracle_sql_rules`で置き換えられる箇所（NVL → COALESCEなど）を先に置き換える。
5. **変換する**: 下記「変換の方針」と`workshop-custom-rules/SKILL.md`のルールに従って残りを書き換え、
   `validate_pg_sql`で検査する。指摘があれば直して検査し直す（最大3回程度）。
   PostgreSQLで作成できるかを早く確かめたいときは、`check_postgres_sql`（実行してからROLLBACKし、変更を残さない）を
   使ってよい。これは実行テストの代わりにはならない（手順6は必ず行う）。
6. **実行して確かめる**: Oracleでは移行元にある元のオブジェクトを、PostgreSQLでは`run_postgres_sql`で作成した変換後の
   オブジェクトを**実行して**結果を比べる（プロシージャは`CALL`、ファンクションは`SELECT`）。CREATEが成功しただけでは`pass`にしない。
   テストケースは`tool-test-viewpoints`の観点（正常系、境界値、異常系、エッジケース）で作る。
   - **移行元のOracleのオブジェクトを作り直さない**: Oracleでは、対象や参照先のオブジェクトに`CREATE OR REPLACE`、`DROP`、
     `ALTER`を実行しない。入力のDDLの定義がOracleの実際の定義と違うことがある（DMS SCの変換前のSQLでは、DBリンクの`@`以降が
     落ちることがある）ため、入力のDDLで作り直すと、移行元のオブジェクトが壊れる。
   - **あるかどうかは`DBA_*`で確かめる**: 接続ユーザーの権限では`ALL_*`（`ALL_SYNONYMS`、`ALL_DB_LINKS`など）に出ない
     オブジェクトがある。`DBA_OBJECTS`、`DBA_SYNONYMS`、`DBA_DB_LINKS`か`DBMS_METADATA.GET_DDL`で確かめる。`ALL_*`に出ないことを、
     ないことの根拠にしない。
   - Oracleにない、または`INVALID`の場合は、作成や再コンパイルをしてよいかをユーザーに尋ねる（勝手に作らない）。
     そのままでは実行できない場合（DBリンクの接続先がないなど）は、DBリンクを使わずに同じ表を参照するなど、
     移行元を変えずにできる方法で比べ、その旨を「注意事項」に書く。
   - テストのためのデータは入れてよい（テストの後で削除する）。テストのために一時的なオブジェクトが必要な場合は、
     既存のオブジェクトと重ならない名前で作り、テストの後で削除する。
   COMMIT / ROLLBACKを含むプロシージャの`CALL`は、ほかの文と混ぜずに単独で送る（1回で送った複数の文は1つの
   トランザクションとして実行され、COMMITが失敗する）。結果の確認は別の呼び出しで行う。
   テストデータの準備には、元の定義（列の型など）を使う。
   作成や実行がエラーになったら、エラーを見て直して試す。直しても**同じエラー（SQLSTATEとメッセージ）が2回続いたら**、
   それ以上は直さずに打ち切り、`fail`のNG.txtにして、エラーと試したことを「失敗情報」に書く。
7. **結果を書き出す**: `write_db_result`で`./result/<オブジェクト名>/`に書き出す。
   - `oracle_sql`には手順3で取得した元のOracleの定義を渡す（converted.sqlのコードは変換後のPostgreSQLなので渡さない）。
   - `status`は`tool-review-status`の判定区分、`summary`は`tool-output-layout`の雛形のとおりに書く。
   - `prerequisites`には、手順1〜3で確かめたこと（対象と依存オブジェクトの有無、定義をどこから取得したか）を書く。
   - `oracle_test_sql` / `oracle_test_result`、`postgres_test_sql` / `postgres_test_result`には、実際に実行したSQLと
     返された結果を、`comparison_result`にはケースごとの比較を書く（`tool-output-layout`）。
8. **変換パターンを提案する**（前半の対話的な変換のときだけ）: 覚えておく価値のある変換パターンを見つけたら、
   まず結果の最後に「変換パターンの追記案」という見出しで、追記したい内容を文章で示し、`workshop-custom-rules/SKILL.md`に
   追記してよいかを尋ねる。参加者が了承したら（修正を求められたら直してから）、`write_skill_draft`で追記する。
   **了承を得る前に`write_skill_draft`を呼ばない**（このツールは、呼んだ時点でファイルに追記する）。
   追記するのは、示して了承された内容だけにする（追記のときに項目を足さない。足したい場合は、もう一度案を示す）。

## DMS SC / SCTの出力がない場合

1. 「元のOracle定義の取得」の2の方法で、Oracleから対象と、それが参照するオブジェクト（型、表など）の定義を取得する。
2. 参照しているオブジェクトがPostgreSQLにあるかを`run_postgres_sql`で確かめる。ない場合は、作成してよいかを尋ねる
   （勝手に作らない）。
3. 元の定義を一から変換し、上の手順4〜7で検査、実行、書き出しをする。
4. Action Itemの情報がないことと、DMS SC / SCTの変換結果を使っていないことを、`summary`の「注意事項」に書く。

## 元のOracle定義の取得

converted.sqlには変換後のPostgreSQLしかない。元の定義は、次の順で取得する。**推測で作らない**。

1. 入力と同じディレクトリに元のOracleのDDL（`DDL_oracle.sql`など）があれば、`parse_dms_sc_converted_sql`に
   `object_name`を指定して取り出す。
2. なければ、`run_ora_sql`でOracleから取得する:
   `SELECT DBMS_METADATA.GET_DDL('<種類>', '<オブジェクト名>', '<スキーマ名>') FROM DUAL`
   （種類は`PROCEDURE`、`FUNCTION`、`PACKAGE`、`TRIGGER`、`VIEW`、`TABLE`など。名前は大文字）。
   参照している表の列の型も、`GET_DDL('TABLE', ...)`または`DBA_TAB_COLUMNS`で確かめる。
   1で取り出した定義に、DBリンク（`@`）やスキーマ名が欠けているように見える場合も、2の方法でOracleの実際の定義を確かめる。
   違う場合は、Oracleの実際の定義を正とし（`oracle_sql`にもこれを渡す）、違いを「注意事項」に書く。
3. それでも取得できなければ、「元のOracleの定義が見つかりませんでした。Oracle側のソースコードを教えてください」
   のようにユーザーに尋ねる。

推測で補った箇所は、`summary`の「注意事項」に書く。

## 実行テストで差異が出たとき

結果が一致しない、または文字化けしている（`�`など）場合は、変換の誤りと決めつけず、次を確かめる。

- Oracleの文字コード: `SELECT value FROM nls_database_parameters WHERE parameter = 'NLS_CHARACTERSET'`
  （各国語の文字コードは`NLS_NCHAR_CHARACTERSET`）
- 対象の列の型（`VARCHAR2`、`NVARCHAR2`、`CHAR`、`RAW`、`BLOB`など）
- PostgreSQLの文字コード: `SHOW server_encoding`

確かめた結果と原因の見当（例: `RAW`の列を文字列として連結している、データベースの文字コードが異なる）を
`comparison_result`と`summary`に書く。**データを書き換えたり、比較の対象から外したりして、差異を消してはならない**。

## 変換の方針

- SCTが一度変換しているので、SCTが対応できなかった部分だけを仕上げる。正しく変換済みの部分は書き換えない。
  converted.sqlに書き換えが必要な箇所が残っていなければ（SCTがすでにCOMMITを削除しているなど）、そのまま使い、
  判定区分を`sct_already_handled`にする。
- オブジェクトの種類（FUNCTION / PROCEDURE）は変えない。変えると呼び出し方と呼び出し元が変わる。どうしても変える必要がある
  場合は、`write_db_result`の`kind_change_reason`に理由を書き、`summary`の注意事項にも書く。
- SCTの出力にある`aws_oracle_ext.*`（AWS SCT拡張パック）は、書き換えずにそのまま使う。
- SCTが元のOracleの文を残したコメント（`/* [NNNN - Severity ... - ...] ... */`）は、PostgreSQLの文に置き換えたうえで
  削除する。最終的なコードにOracleの構文を残さない。
- 書き換えた行の直前には、次のマーカーを付ける（複数のAction Itemはカンマで区切る。SCTが変換済みの行には付けない）:
  `/* [scaw2.0] converted from action_item=<番号> */`
- COMMIT / ROLLBACK（Action Item 5034 / 5035）: PROCEDUREの中で、EXCEPTION句の外にあり、トップレベルから`CALL`される
  ものは残す。EXCEPTION句を持つブロックの中にある、FUNCTIONである、呼び出し元がトランザクションを持つ、のどれかなら削除して
  呼び出し元に任せる。FUNCTIONをPROCEDUREに変えたり、EXCEPTION句の位置を変えたりしてCOMMITを残すことは、呼び出し元や
  エラー処理の順序が変わるため、自分の判断では行わず要確認として提案する。例外ハンドラの`ROLLBACK; RAISE;`のROLLBACKは不要なので削除する（ROLLBACKした後に処理を続けるものは
  要確認）。どちらにしたかと理由を`summary`に書く（例: 「EXCEPTION句を持つブロックの中ではCOMMIT/ROLLBACKを使えないため」）。
  「PostgreSQLのプロシージャはトランザクション制御をサポートしない」とは書かない。詳しくは`domain-conversion-rules`の
  references/plsql-plpgsql.md「トランザクション制御」。
- DMS SC形式でAction Itemが付いたオブジェクトは、全体を書き直すか、該当する行だけを直すかをその都度判断する。
  Action Itemが数行に集まっているなら、その行だけを直す（正しく変換済みの部分まで書き直すと、誤りを入れる危険が増える）。
  オブジェクト全体に広がっている、または種類の違うAction Itemが絡み合っているなら、全体を見直す。
  Action Itemの内容が下記の構造的な書き換えにあたるかも確かめる。迷ったらユーザーに相談する。

### 構造的な書き換えが必要なもの

次のものは、その場の書き換えでは正しく表せない。本体を書き換えず、SCTのコメントを残したまま、その直前に
`/* [scaw2.0] NEEDS_STRUCTURAL_REWRITE: <理由を1行で> */`を付け、判定区分を`manual_review_range`にする。

- ジョブやキュー: `DBMS_SCHEDULER`、`DBMS_AQ`（pg_cronやアプリケーション側の仕組みが必要）
- 外部との通信やファイル: `UTL_HTTP`、`UTL_SMTP`、`UTL_FILE`、`UTL_TCP`
- 別のデータベース: DB LINK経由の読み書き（参照先がOracleに残るならoracle_fdw、別のPostgreSQLに移るならpostgres_fdwが必要。
  postgres_fdwはOracleに接続できないので、この2つを取り違えない。
  参照先が同じデータベースに移るなら、ビューやスキーマ名付きの参照で書ける。どれにあたるかは推測せず、移行後の参照先をユーザーに確かめる。
  書き方は`domain-conversion-rules/references/structural-conversions.md`の「データベースリンク」を参照）
- 動的な列のメタデータ: `DBMS_SQL.DESCRIBE_COLUMNS`など
- 自律型トランザクション: `PRAGMA AUTONOMOUS_TRANSACTION`（SCTが`aws_oracle_ext.autonomous_exec`で置き換えている場合はそのまま使う）
- スキーマの設計の見直し: パッケージを名前空間として使う設計、CLUSTER表、直接の対応がないXMLTYPEの関数
- MATERIALIZED VIEWへの直接のDML: 「元の表へのDML + REFRESH」では表せず、アプリケーション側の設計の見直しが必要。
  DMLを黙ってコメントアウトして「対応済み」に見せかけない

PostgreSQLの組み込みの機能、`aws_oracle_ext.*`、標準のPL/pgSQL、`information_schema`で書けるもの（NVL、DECODE、
SYSDATE、ROWNUM、CONNECT BY、LISTAGG、DBMS_OUTPUT、DBMS_RANDOM、CURSOR、`:NEW` / `:OLD`、例外処理など）は、
本体を書き換える。どちらか迷ったら`NEEDS_STRUCTURAL_REWRITE`にする（推測で本体を書かない）。

### SCTが変換をあきらめたブロック（Action Item 9996）

`/* [9996 - Severity CRITICAL - Transformer error occurred in ...] ... */`のコメントと空の`BEGIN END;`が残っている
場合は、そのまま残す（コメントを外さない、削除しない）。コメントの中は実行されない文字列なので、中のOracle構文も
変換しない。判定区分は`partial_by_llm`にし、人の確認が必要な理由と、それ以外の部分は変換できていることを書く。

## 後半: 残りをまとめて変換する

1. `list_converted_objects`で変換済みのオブジェクトを調べ、`parse_sct_csv`の対象と比べて残りの一覧を作る
   （どちらもスキーマ名を除き、大文字にして比べる）。
2. 残りの一覧を示し、続けてよいかを確かめる。ワークショップでは、並列に変換する`scaw-migration-db-batch`を案内する。
3. 1件ずつ上の手順で変換する。`workshop-custom-rules/SKILL.md`を最優先の参考にする。
4. 行数の多いオブジェクトは、決まった行数で区切らず、分け方（機能ごと、ブロックごとなど）をユーザーと相談してから変換する。

`workshop-custom-rules/SKILL.md`とこのSkillの内容が食い違う場合は、どちらかを黙って優先せず、参加者に確認する。
