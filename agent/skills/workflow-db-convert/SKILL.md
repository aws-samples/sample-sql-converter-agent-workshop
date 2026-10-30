---
name: workflow-db-convert
description: Per-object Oracle→PostgreSQL conversion of database schema / PL/SQL / procedures after AWS SCT has done the first pass. Use when the user asks "SCTで変換できなかったオブジェクトを変換して", "converted.sqlのこのオブジェクトを変換して", or gives a target object name. SCAW2.0 版 — LLM呼び出しはMCPツール内部ではなくエージェント自身が担う構成。
---

# Database Object Convert（SCAW2.0版）

SCTが変換を試みた後の、Oracle DBオブジェクト（テーブル、ビュー、ファンクション、
トリガー、プロシージャ、パッケージ）のPostgreSQLへの変換を、db worker
（`scaw-migration-db`）が担当する。

SCAW2.0はKiro CLIチャット単一サーフェスという制約上、MCPツール層はLLM
APIを直接呼ばない方針である。**この対話ではエージェント
自身がLLM変換の役割（プロンプト構築・変換生成）を担い、MCPツールは決定的
な検証（validate_pg_sql等）だけを行う**。変換方針（後述）はこのSKILL.md
本文にまとめている。

## この skill を使う場面

- 「SCTで変換できなかったオブジェクトを変換して」
- 「converted.sqlの`SCHEMA.PROC_NAME`を変換して」
- 「残りのオブジェクトも全部変換して」（後半の一括変換、下記参照）

app trackの埋め込みSQL変換には使わない（`workflow-app-convert`を使う）。

## 入力

| ファイル | 必須か | 用途 |
|---|---|---|
| `detail.csv`相当 | 必須 | Action Items Detail。`parse_sct_csv`で対象オブジェクト名を特定する |
| `summary.csv`相当 | 必須 | Action Items Summary。同上 |
| `converted.sql`相当 | 必須 | 変換結果（変換後のPostgreSQL DDL）。変換の起点にする |
| 元のOracle DDL（例: DMS SCの`DDL_oracle.sql`） | 任意 | 変換前のOracleの定義。`oracle.sql`の出力、Oracle側の実行テスト、差異の調査に使う（下記「元のOracle定義の取得」参照） |

**入力の出所は2種類ある**:

1. **AWS SCT単体ツール**: `detail.csv` / `summary.csv` / `converted.sql`という
   固定名。`converted.sql`はオブジェクト単位のマーカーで区切られる。
2. **AWS DMS Schema Conversion（DMS SC）**: ファイル名は
   `{RDSエンドポイント名}.csv`（detail相当）/ `{...}_Action_Items_Summary.csv`
   （summary相当）のような動的名で、`converted.sql`相当ファイルは
   `-- ------------ Write CREATE-XXX-stage scripts -----------`という
   **ステージ見出し**でオブジェクトがグルーピングされる。

**S3パスが渡された場合**: `s3://`で始まるパスを受け取ったら、MCPツール
`download_s3_input`でリポジトリの`input/db-object/assessment/`に
ダウンロードし、以降は返されたローカルファイルのパスを使う（ZIPは自動で
展開される）。`aws s3 cp`などのシェルコマンドは使えない（このエージェントは
シェルを実行するツールを持たない）。

- 1ファイル（`s3://bucket/key`）、フォルダ（`s3://bucket/prefix/`）、
  パターン（`s3://bucket/prefix/*.zip`）のいずれも指定できる。
- DMS SCの出力は、`ORACLE_POSTGRESQL_<日時>.zip`（アセスメントのCSV 3つ）、
  `Oracle-<日時>.zip`（元のOracle DDL）、`PostgreSQL-<日時>.zip`（変換後の
  PostgreSQL DDL）に分かれている。展開後は、`<エンドポイント名>.csv`を
  detail相当、`<エンドポイント名>_Action_Items_Summary.csv`をsummary相当、
  `PostgreSQL-<日時>.sql`を`converted.sql`相当、`Oracle-<日時>.sql`を
  元のOracle DDLとして扱う。
- 同じ名前のファイルが既にある場合は上書きされず、`skipped`として返る。
  同じ実行結果を取り直す場合だけ、ユーザーに確認したうえで`overwrite=True`にする。
- ダウンロード先は`input/`（gitの管理対象外）の中に限られる。

**入力形式の判別（`converted.sql`相当ファイルを受け取ったら最初に行う）**:
ファイルの内容を確認し、`-- ------------ Write ...-stage scripts -----------`
という見出しコメントが含まれていれば **DMS SC形式**、含まれていなければ
**SCT単体形式**と判定する。ユーザーに事前にどちらの形式かを尋ねる必要はない
（ファイルを見れば判別できる）。

- SCT単体形式 → `parse_sct_converted_sql`を使う（下記ワークフローそのまま）
- DMS SC形式 → `parse_dms_sc_converted_sql`を使う（下記「DMS SC形式の場合の
  追加ステップ」参照）

**大きいconverted.sqlの扱い（必須）**: 実案件のconverted.sqlは数十MB・
数千オブジェクトになることがある。全オブジェクトをcode付きで返させると
MCP応答が巨大になり、MCPサーバーが落ちる（以降のツール呼び出しが全て
「Not connected」になる）。以下を守ること:

- 1オブジェクトを変換するときは、`parse_sct_converted_sql` /
  `parse_dms_sc_converted_sql`に**必ず`object_name`を指定する**
  （例: `object_name="SCHEMA.PROC_A"`、スキーマ省略の`"PROC_A"`も可）。
  ファイル全体を読む必要はない。
- **converted.sqlを自分で分割（`split`コマンド等で`converted_part1.sql`
  のようなファイルを作る）しない**。`object_name`を指定すれば元の
  ファイルのままでよい。
- 一覧（残りリスト作成等）が必要なときは`object_name`なしで呼ぶ。応答が
  上限サイズを超える場合は自動的にcodeを省略した一覧
  （`code_omitted: true`）になるので、そのまま一覧として使う。
- `inline=False`で書き出されたキャッシュJSON（`.cache/*.json`）は巨大に
  なり得るため、`fs_read`で直接読まない。

## 元のOracle定義の取得

変換後のコード（`converted.sql`）だけでは、変換前のOracleの定義が分からない。
元の定義は、`oracle.sql`への出力、Oracle側の実行テスト（ステップ5）、
差異が出たときの調査（列の型、文字コード）に必要になる。対象オブジェクトの
元の定義は、以下の順で取得する。

1. **元のDDLファイルがあれば、そこから取り出す**: 入力と同じディレクトリに、
   Oracle側のDDLをまとめたファイル（DMS SCの`DDL_oracle.sql`など）がある
   場合は、`parse_dms_sc_converted_sql`に`object_name`を指定して、対象
   オブジェクトのブロックだけを取り出す（Oracleの`CREATE OR REPLACE ...`も
   同じ方法で分割できる）。ファイル全体を読まない。
2. **ファイルがなく、Oracleに接続できる場合は、`run_ora_sql`で取得する**:
   ```sql
   SELECT DBMS_METADATA.GET_DDL('<オブジェクトの種類>', '<オブジェクト名>', '<スキーマ名>') FROM DUAL
   ```
   （種類は`PROCEDURE` / `FUNCTION` / `PACKAGE` / `TRIGGER` / `VIEW` / `TABLE`など。
   名前は大文字で指定する）。対象オブジェクトが参照しているテーブルの列の
   型も、同じように`GET_DDL('TABLE', ...)`または`ALL_TAB_COLUMNS`で確認する。
3. **どちらもできなければ、ユーザーに尋ねる**: 例「元のOracleの定義が
   見つかりませんでした。Oracle側のソースコードを教えてください」。

取得できなかった場合は、推定で補った箇所を`OK.txt`/`NG.txt`の「注意事項」に
明記する。

## 実行テストで想定外の差異が出たとき（文字化けなど）

ステップ5の実行テストで、Oracle側とPostgreSQL側の結果が一致しない、または
値が文字化けしている（`�`など）場合は、変換の誤りと決めつけず、以下を確認する。

- Oracleのデータベースの文字コード:
  `SELECT value FROM nls_database_parameters WHERE parameter = 'NLS_CHARACTERSET'`
  （各国語文字コードは`NLS_NCHAR_CHARACTERSET`）
- 対象の列の型（`VARCHAR2` / `NVARCHAR2` / `CHAR` / `RAW` / `BLOB`など）。
  元の定義は上記「元のOracle定義の取得」の方法で確認する
- PostgreSQLのデータベースの文字コード: `SHOW server_encoding`

確認した結果と原因の見当（例: 列が`RAW`で文字列として連結している、
データベースの文字コードが異なる）を、`test_result.txt`と`NG.txt`に書く。
**データを書き換えたり、比較の対象から外したりして、差異を消してはならない**。

## ワークフロー（対話的1件変換）

```
1. [parse_sct_csv]
   detail.csv/summary.csvをパースし、変換失敗/manual-review対象のオブジェクト名
   リスト + action item情報を抽出する（決定的、LLM不使用）。

2. [parse_sct_converted_sql]
   converted.sqlを CREATE [OR REPLACE] ... 単位に分割し、対象オブジェクト名で
   ブロックをマッチングする（決定的）。**対象オブジェクトが決まっている場合は
   必ず`object_name`引数を指定し、そのブロックだけを取得する**（下記
   「大きいconverted.sqlの扱い」参照）。

   ブロックが存在し、かつ空/コメントのみでない？
     Yes → 3へ
     No  → 下記「元のOracle定義の取得」の順（元のDDLファイル → GET_DDL →
           ユーザーに尋ねる）で元の定義を取得し、それを3の入力として使う。

3. [convert_oracle_sql_rules]
   決定的ルール変換を試行する（NVL→COALESCE等、約20パターン）。適用可能な
   部分があれば先に適用し、残りをLLM変換の入力にする。

4. [LLM変換ループ] — エージェント自身が下記「変換方針」に従って実行
   a. 下記の変換方針に従い、PostgreSQL変換を生成する
   b. MCPツール validate_pg_sql を呼び、構文+Oracle残留チェック（決定的）
   c. NG → 検証結果を見て、エージェントが再度変換を試行する（最大3回程度）
   d. OK → 5へ

5. [簡易実行テスト]（agent/mcpserver/ 再利用、SCAW1.0からの意図継承）
   - run_ora_sql: 元のOracle動作確認（可能な範囲で）
   - run_postgres_sql: 変換後PostgreSQLでの実行確認
   validate_pg_sqlの静的検証に加え、実行結果による動的検証を行う。
   Oracle側のテストやテストデータの準備には、元の定義（上記「元のOracle
   定義の取得」）を使う。結果が一致しない場合は、上記「実行テストで想定外の
   差異が出たとき」に従う。

6. [write_db_result]
   ./result/<オブジェクト名>/ に出力:
   - oracle.sql（元のOracle DDL/コード。上記「元のOracle定義の取得」で取得したもの。
     converted.sqlのコードは変換後のPostgreSQLなので、ここには入れない）
   - postgres.sql（変換後PostgreSQL）
   - test_result.txt（簡易テスト結果、上記のreview status語彙で結果を説明する
     — tool-db-inventory-schema参照）
   - OK.txt または NG.txt（`status`と`summary`を必ず渡すこと。省略すると
     SCAW1.0相当のサマリーが残らない）。`status`からOK/NG判定されるので
     review status語彙の値（`pass`等）を渡す。`summary`は短い自由記述では
     なく、**必ず以下の見出し構成のまま**（省略・簡略化・独自の見出しへの
     差し替えをしない）、各項目を埋めて渡すこと（SCAW1.0形式、
     tool-output-layout参照）:

     ```
     ## 基本情報
     - ステータス: <SUCCESS/FAILED、またはreview-status語彙の値>
     - 変換対象: <オブジェクト名、タイプ（PROCEDURE/FUNCTION/TRIGGER等）>
     - 実施日時: <YYYY-MM-DD HH:MM:SS>

     ## 変換の主な変更点
     - データ型変更: <例: VARCHAR2(100) → VARCHAR(100)。なければ「なし」>
     - 構文変更: <例: NVL() → COALESCE()。なければ「なし」>
     - 削除した機能: <例: トランザクション制御（COMMIT/ROLLBACK）、理由: ...。なければ「なし」>

     ## テスト結果サマリー
     - 実行したテストケース数: <X件>
     - 成功/失敗の内訳: <成功 X件 / 失敗 Y件>

     ## 注意事項
     - <運用時に注意すべき点。対応するaction item番号、推定で補った箇所、
       要確認事項などはここに記載する>

     ## （NG.txtの場合のみ）失敗情報
     - 失敗理由: <具体的なエラー内容>
     - 試行回数: <X回>
     - 推奨される対応方法: <手動対応が必要な箇所、追加確認すべき依存関係>
     ```

     良くない例（見出しのない自由記述、禁止）:
     ```
     esuserd.esfc0451 (function) : pass
     - action item 5034/5035に対応。
     - 要確認: ...
     ```

7. [write_skill_draft]（前半の対話的変換時のみ）
   今回の変換で発見した変換パターンを workshop-custom-rules/SKILL.md への
   追記案としてエージェントが提示する。参加者がレビュー・編集する。
```

## LLM変換方針

これは変換ノウハウであり、SCAW2.0ではエージェントがこの方針に従って直接
変換を生成する。

### 基本方針

Oracle PL/SQL / DDLをPostgreSQLに変換する。ソースは既にAWS SCTが一次変換を
試みているので、SCTが対応できなかった部分を仕上げるのが仕事である。

SCTは変換できなかった箇所に、しばしば元のOracle文をコメントブロックとして
残す（`/* [NNNN - Severity ... - <SCTメッセージ>] <元のOracle SQL> */`）。
このコメントに対応するaction itemが変換可能（CONVERTIBLE）な場合は、
(1) コメントの代わりにPostgreSQL相当の文を書き、(2) SCTコメントブロックを
削除して、最終的なコードにOracle構文の残留がない状態にする。よくある変換例:

- `SELECT <expr> FROM DUAL` → `SELECT <expr>` またはその代入
- `FROM DUAL` → 削除
- `ROWNUM <= n` → `LIMIT n`
- `DECODE(a,b,c,d)` → `CASE WHEN a=b THEN c ELSE d END`
- `NVL(a,b)` → `COALESCE(a,b)`
- `VARCHAR2(n)` → `VARCHAR(n)`
- `/*+ hint */` → 削除（PostgreSQLはOracleヒントを無視する）

### 出所マーカー（PROVENANCE）

書き換えた行・ブロックの直前に、以下の形式のマーカーを1行挿入する:

```
/* [scaw2.0] converted from action_item=<IDs> */
```

（複数のaction itemが該当する場合はカンマ区切り）。SCTが既に変換済みの
コードにはマーカーを付けない — 自分が書き換えた行にのみ付ける。

### 構造的書き換えが必要かどうかの判定（順に評価、最初にYesが出たら確定）

1. 対象のaction itemが、pg_cron / pgAgent / AWS Lambda / postgres_fdw /
   アプリケーション層（キューイング、HTTP、SMTP）/ スキーマ再設計
   （パッケージの名前空間化、MATERIALIZED VIEWへのDML戦略、CLUSTER）/
   カスタムPL/pgSQLヘルパー（DBMS_SQLのメタデータ、直接対応のないXML）を
   必要とするか？
   → **Yes: 構造的書き換えが必要。以下のマーカーを付けて停止する**:
     ```
     /* [scaw2.0] NEEDS_STRUCTURAL_REWRITE: <一行で理由> */
     ```
     このマーカーはSCTコメントブロックの直前に、SCTコメントブロック自体は
     そのまま残した状態で挿入する。このオブジェクトは`manual_review_range`
     として扱われ、Oracle構文の残留として減点されない。

2. (a) PostgreSQL組み込みの演算子/関数（COALESCE, CASE, 配列演算, `||`）、
   (b) `aws_oracle_ext.*`ラッパー（利用可能であれば。SCAW2.0では
   AWS SCT拡張パックの利用を前提としない場合は、素朴なPostgreSQL関数で
   代替してよい — 例: `SYSDATE`→`CURRENT_TIMESTAMP`または
   `aws_oracle_ext.sysdate()`のいずれか、環境に応じて判断する）、
   (c) PL/pgSQLの`$$ 本体 $$`＋標準的な制御構文、(d) `information_schema`
   クエリのいずれかで表現できるか？
   → **Yes: 本体を書き換える。NEEDS_STRUCTURAL_REWRITEマーカーは付けない**

3. それでも判断に迷う場合は、`NEEDS_STRUCTURAL_REWRITE`をデフォルトとする
   （当てずっぽうで本体を書かない）。

### 典型例（構造的書き換えが必要 / 不要）

**構造的書き換えが必要**:
`DBMS_SCHEDULER.CREATE_JOB` / `DROP_JOB`、`DBMS_AQ.ENQUEUE` / `DEQUEUE`、
DB LINK経由の読み書き、`DBMS_SQL.DESCRIBE_COLUMNS`等の動的カラムメタデータ、
`UTL_HTTP` / `UTL_SMTP` / `UTL_FILE` / `UTL_TCP`、
MATERIALIZED VIEWへの直接DML（INSERT/UPDATE/DELETE）— **重要**: これは
「ベーステーブルへのDML + REFRESH」というインラインの書き換えでは表現でき
ない。元の意味（アプリがMVIEWに直接書き込む）はMVIEWがテーブルであること
に依存しているため、正しい対応はアプリケーション層でベーステーブルに対して
再設計すること。DMLを黙ってコメントアウトして「対応済み」と偽装しては
ならない。
パッケージを名前空間として使うケース、CLUSTERテーブルの物理構成、
直接対応のないXMLTYPE関数。

**構造的書き換え不要（本体を書き換える）**:
NVL / DECODE / SYSDATE / ROWNUM / CONNECT BY / LISTAGG、
`DBMS_OUTPUT.PUT_LINE` → `RAISE NOTICE`等、`DBMS_RANDOM` → `random()`、
`DBMS_LOB.GETLENGTH` → `length()` / `octet_length()`、
`VARCHAR2` / `NUMBER` → `VARCHAR` / `NUMERIC`、Oracleヒント`/*+ ... */` →
削除、`CURSOR` → `FOR cur IN (...) LOOP` / `RETURN QUERY`、
`FROM DUAL` → 削除 または `VALUES (...)`、`:NEW` / `:OLD` → `NEW` / `OLD`、
`EXCEPTION WHEN OTHERS` → 標準的なPostgreSQL例外処理。

### SCT Transformer error（action item 9996）の扱い

SCTが構文の変換を完全に諦め、以下のようなブロックを残すことがある:

```
/*
[9996 - Severity CRITICAL - Transformer error occurred in ...]
<SCTが変換できなかった元のOracleコード>
*/
BEGIN END;  -- またはSCTが残した空のプレースホルダ
```

これらはデッドコードである。SCTもエージェントもPostgreSQL相当を生成できない
（SCTが詰まった言語機能はインラインで表現できる直接の対応先がない）。

**このブロックへの対応**:
- そのまま保持する。コメントを外さない。削除しない。
- コメント内の本体を書き換えようとしない — 見た目は合っていても間違った
  ものを生成するリスクが高く、SCTのマーカーは人間レビュアーへの
  「ここから確認して」という目印である。
- コメント内のOracle構文（`DBMS_OUTPUT.PUT_LINE`、`SQL%BULK_ROWCOUNT`、
  `ROWNUM`等）を変換しようとしない — コメントテキストであり実行コードでは
  ない。

これらのブロックが残っている場合、`test_result.txt`で`partial_by_llm`相当
として報告し、人間レビューが必要な理由を明記する（他の部分は正常に変換
できていることも伝える）。

## DMS SC形式の場合の追加ステップ

`converted.sql`相当ファイルがDMS SC形式と判定された場合、上記ワークフローの
ステップ2（`parse_sct_converted_sql`）の代わりに`parse_dms_sc_converted_sql`
を使う。挙動の違いは以下の通り:

```
2'. [parse_dms_sc_converted_sql]
    converted.sql相当ファイルをオブジェクト単位のブロックに分割する
    （ステージ見出しコメントは無視し、CREATE OR REPLACE文の出現位置で
    分割する。決定的処理）。各ブロックについて、DMS SCのインライン
    Action Itemマーカー（`/* [<番号> - Severity <重大度> - <説明>] */`）
    の有無を検出し、status（"converted" or "action_items"）を返す。
    **対象オブジェクトが決まっている場合は必ず`object_name`引数を指定する**
    （下記「大きいconverted.sqlの扱い」参照）。

    対象オブジェクトのブロックが見つかったか？
      No  → ステップ2のNo分岐と同様、対話でユーザーに尋ねる
      Yes → statusを確認する
              "converted"（Action Itemなし）
                → そのままステップ3（convert_oracle_sql_rules）以降、
                  通常のフローに合流する
              "action_items"（Action Item付き）
                → 下記の判断ステップへ
```

**"action_items"の場合の判断（対象オブジェクト全体の再変換 vs 該当行の
差分修正）**: これは固定ルールで決めない。対象オブジェクトの実際の状態
を見て、エージェントが都度判断する。判断の参考にする観点:

- **Action Itemの件数・分布**: ブロック内の一部の行（数行程度）にのみ
  Action Itemが集中している場合は、その部分だけを直す**差分修正**が
  自然（オブジェクトの大部分はDMS SCが正しく変換済みのため、無関係な
  部分まで書き直すと不要なリスクを増やす）。逆にAction Itemがブロック
  全体に広く分布している、あるいは複数の異なるAction Item種別が絡み
  合っている場合は、**オブジェクト全体を見直す**方が安全なことがある。
- **Severityと内容**: 上記「構造的書き換えが必要かどうかの判定」の
  基準をここでも適用する。個々のAction Itemが指す内容が構造的書き換え
  相当（DBMS_SCHEDULER, UTL_HTTP等）であれば、そのAction Item箇所には
  `NEEDS_STRUCTURAL_REWRITE`マーカーを付ける。単純な構文置き換えで
  済むもの（COMMIT/ROLLBACKの扱い変更等）であれば差分修正で対応する。
- **確信が持てない場合**: 対話でユーザーに「この部分は差分修正で対応
  できそうですが、オブジェクト全体を見直したほうがよいですか？」等と
  相談する（大きなオブジェクトを分割して扱う場合と同様、対話的に判断する）。

差分修正の場合も、変換した箇所には通常と同じPROVENANCEマーカー
（`/* [scaw2.0] converted from action_item=<IDs> */`）を付ける。

## 1-1. 後半: 一括変換フロー

前半で複数オブジェクトを変換し、`workshop-custom-rules/SKILL.md`が育った
段階で、参加者が「残りのオブジェクトも変換して」と指示すると以下が起動する。

```
1. list_converted_objects(result_dir) で ./result/<obj>/ が既に存在する
   オブジェクトを列挙する。
2. 手順1の`parse_sct_csv`で抽出した対象オブジェクトリストと比較し、「残りリスト」を作る。
3. エージェントが残りリストを提示し、続行確認を取る。
   例:「残りは12件です（PROC_A, PROC_B, ...）。workshop-custom-rulesの
        ルールを適用して順に変換します。続けますか？」
4. 確認OK → 1オブジェクトずつ、上記の対話的1件変換フローを繰り返す。
   ただし変換時に workshop-custom-rules/SKILL.md（レビュー済み）を
   最優先の参照ルールとして使う（load_custom_rules で読み込む）。
5. 大規模オブジェクト（コード行数が多いプロシージャ/ファンクション）を
   検出した場合、エージェントが「このオブジェクトは行数が多いため
   分割変換を提案します」と対話的に提示する。決定的な文字数閾値ルールは
   設けない — ユーザーと相談し、分割方針（機能単位、ブロック単位等）を
   決めてから変換を進める。大きいオブジェクトの一部だけを扱う場合は
   `code_splitter.extract_snippets` / `extract_routine_snippet`が
   参考になる（署名+SCTマーカー周辺のみを抜き出すヘルパー）。
```

## プロジェクト固有ルール（workshop-custom-rules）

変換を始める前に、必ず`load_custom_rules(project_root=<dir>)`を呼び、
`workshop-custom-rules/SKILL.md`の内容を確認する。見つかった場合は
`format_custom_rules_for_prompt`でプロンプト用に整形し、変換方針の
参考にする。**SCAW2.0はCRITICAL POLICYが常に優先されるという固定的な優先順位を設けない**
— このファイルの内容と本skillの内容が競合した場合は、参加者に確認する。

## Related skills

- [workflow-app-convert](../workflow-app-convert/SKILL.md) — app track埋め込みSQLの変換
- [domain-conversion-rules](../domain-conversion-rules/SKILL.md) — Oracle→PostgreSQL変換ルール一覧
- [tool-db-inventory-schema](../tool-db-inventory-schema/SKILL.md) — review status語彙
- [tool-output-layout](../tool-output-layout/SKILL.md) — 出力ファイルの配置
