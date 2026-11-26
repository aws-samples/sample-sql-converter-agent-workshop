---
name: domain-conversion-rules
description: Oracle → PostgreSQLのSQL・DDL・関数・データ型の変換ルール集。特定のOracleの構文（NVL、DECODE、SYSDATE、ROWNUM、CONNECT BY、LISTAGG、MERGE、(+)結合、FROM DUALなど）のPostgreSQLでの書き方を調べるとき、データ型（VARCHAR2、NUMBER、DATE、CLOB）を対応付けるとき、PL/SQLとPL/pgSQLの違いを確かめるときに使う。変換の手順そのものは`workflow-db-convert` / `workflow-app-convert`に従う。
---

# Oracle → PostgreSQL 変換ルール

Oracle SQL・DDL・PL/SQLの構文を、PostgreSQLの書き方に対応付けるルール集。
対象はPostgreSQL 15以降（ワークショップ環境のAurora PostgreSQLは17.7）。

このファイルには、方針、データ型、よく使う変換だけをまとめている。
詳しい対応表は次のファイルにある。

- [references/function-mapping.md](./references/function-mapping.md) — NULLの扱い、文字列・数値・日付時刻・環境の関数
- [references/structural-conversions.md](./references/structural-conversions.md) — 結合、ROWNUM、CONNECT BY、PIVOT、MERGE、INSERT ALL、データディクショナリビュー
- [references/plsql-plpgsql.md](./references/plsql-plpgsql.md) — PL/SQLのブロック、例外処理、カーソル、動的SQL、BULK COLLECT、型、組み込みパッケージ

## 基本方針

- 構文として正しいPostgreSQL 15以降のコードを出力する
- スキーマ名・オブジェクト名は小文字にし、SQLのキーワードは大文字のままにする
- PL/SQLはPL/pgSQLに変換する
- 元のコメントを残す

## AWS SCT拡張パック（`aws_oracle_ext`）

ワークショップ環境のAurora PostgreSQLには、`deploy.sh`でAWS SCT拡張パック（`aws_oracle_ext`スキーマ）を
適用している。SCT / DMS Schema Conversionの変換結果は、この拡張パックの関数を使う前提で出力される。

- SCT / DMS SCの出力にある`aws_oracle_ext.*`は、**書き換えずにそのまま使う**
  （例: `CALL aws_oracle_ext.dbms_output$put_line(...)`、`aws_oracle_ext.systimestamp()`）。
- 自分で新しく書く箇所も、SCTと同じ書き方にそろえる。特に、OracleとPostgreSQLで意味が異なる
  関数（`SYSDATE`、`SYSTIMESTAMP`、`SYS_CONTEXT`、`DBMS_OUTPUT.PUT_LINE`、`MONTHS_BETWEEN`、`NEXT_DAY`など）は
  拡張パックの関数を使う。
- PostgreSQLの標準の機能で同じ意味になるもの（`NVL` → `COALESCE`、`FROM DUAL`の削除など）は、
  標準の機能で書く。
- 1つのオブジェクトの中で、同じ処理を拡張パックと標準の機能の両方で書き分けない。

## 間違えやすいルール（必ず守る）

- `REGEXP_SUBSTR`は`SUBSTRING(... FROM ...)`に変換する。出力に`REGEXP_SUBSTR`を残さない。
- `LISTAGG`は`STRING_AGG(col, delimiter)`にする。`ARRAY_AGG`ではない（型の意味が異なる）。
- `SYSDATE`は`aws_oracle_ext.sysdate()`にする。`NOW()`や`CURRENT_TIMESTAMP`ではない。
- 日付の`TRUNC(date_col)`は`DATE_TRUNC('day', date_col)`にする。PostgreSQLの`TRUNC`は日付を受け付けない。
- `DECODE`を`CASE`にするとき、NULL同士の比較に注意する（`DECODE`は一致とみなし、`CASE`はみなさない）。
- NULLになりうる列を`||`でつなぐ場合は`CONCAT(...)`にする（Oracleは連結でNULLを空文字として扱う）。
  元のSQLの意図と違うと思われる場合も、結果はOracleに合わせ、違いは要確認として伝える（[function-mapping.md](./references/function-mapping.md)）。

## データ型の対応

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| VARCHAR2(n) | VARCHAR(n) | |
| NVARCHAR2(n) | VARCHAR(n) | |
| NUMBER | NUMERIC | 精度の指定なしでもよい |
| NUMBER(p,s) | NUMERIC(p,s) | |
| INTEGER | INTEGER | |
| DATE | TIMESTAMP | OracleのDATEは時刻を含む |
| TIMESTAMP | TIMESTAMP | |
| CLOB | TEXT | |
| BLOB | BYTEA | |
| NCLOB | TEXT | |
| RAW(n) | BYTEA | |
| LONG | TEXT | |
| LONG RAW | BYTEA | |
| BINARY_FLOAT | REAL | |
| BINARY_DOUBLE | DOUBLE PRECISION | |
| BOOLEAN | BOOLEAN | |
| XMLTYPE | XML | |
| ROWID | 対応なし | 主キー、または`ctid`（値が変わりうる）を使う |
| BFILE | 対応なし | アプリケーション側で対応する |

## よく使う変換

| Oracle | PostgreSQL | 詳細 |
|---|---|---|
| `NVL(a, b)` | `COALESCE(a, b)` | function-mapping.md |
| `NVL2(a, b, c)` | `CASE WHEN a IS NOT NULL THEN b ELSE c END` | function-mapping.md |
| `DECODE(expr, v1, r1, ..., def)` | `CASE expr WHEN v1 THEN r1 ... ELSE def END` | function-mapping.md |
| `SUBSTR(s, pos, len)` | `SUBSTRING(s FROM pos FOR len)` | function-mapping.md |
| `SYSDATE` / `SYSTIMESTAMP` | `aws_oracle_ext.sysdate()` / `aws_oracle_ext.systimestamp()` | function-mapping.md |
| `SYS_CONTEXT('USERENV', <属性>)` | `aws_oracle_ext.sys_context('USERENV', <属性>)` | function-mapping.md |
| `ADD_MONTHS(d, n)` | `d + INTERVAL 'n months'` | function-mapping.md |
| `FROM DUAL` | 削除 | function-mapping.md |
| `seq.NEXTVAL` | `nextval('seq')` | function-mapping.md |
| `WHERE ROWNUM <= N`（トップレベル） | `LIMIT N` | structural-conversions.md |
| `(+)`による外部結合 | `LEFT JOIN` / `RIGHT JOIN` | structural-conversions.md |
| `MINUS` | `EXCEPT` | structural-conversions.md |
| `MERGE` | `INSERT ... ON CONFLICT ... DO UPDATE` | structural-conversions.md |
| `CONNECT BY` | `WITH RECURSIVE` | structural-conversions.md |
| `INSERT ALL` | 複数の`INSERT`に分ける | structural-conversions.md |
| `PIVOT` / `UNPIVOT` | 条件付きの集計 / `UNION ALL` | structural-conversions.md |
| ヒント`/*+ ... */` | 削除 | structural-conversions.md |
| `USER_TABLES`など | `information_schema.tables`など | structural-conversions.md |
| `DBMS_OUTPUT.PUT_LINE` | `CALL aws_oracle_ext.dbms_output$put_line(...)` | plsql-plpgsql.md |
| `RAISE_APPLICATION_ERROR` | `RAISE EXCEPTION ... USING ERRCODE` | plsql-plpgsql.md |

## PL/SQL → PL/pgSQL の要点

PL/pgSQLはPL/SQLと考え方は同じだが、構文と動作が異なる。

- **COMMIT/ROLLBACK**: FUNCTIONの中では使えない。PROCEDURE（PostgreSQL 11以降）の中では使えるが、EXCEPTION句を持つ
  ブロックの中や、呼び出し側のトランザクションの中で`CALL`された場合は使えない。残せるものは残し、残せないものは呼び出し元に移す。
  例外ハンドラの`ROLLBACK; RAISE;`のROLLBACKは不要。詳しくは[references/plsql-plpgsql.md](./references/plsql-plpgsql.md)の
  「トランザクション制御」。
- PL/pgSQLでは**関数の中に関数を定義できない**。内側の関数は独立した関数として定義する。
- 例外処理、カーソル属性、動的SQL、BULK COLLECT、型、オブジェクト型は書き方が異なる
  （[references/plsql-plpgsql.md](./references/plsql-plpgsql.md)）。

## 検証

変換した後は、必ずMCPツール`validate_pg_sql`でOracle構文の残りを検出する。
指摘された箇所は、変換が終わったとみなす前に直す。

## 関連するSkill

- [workflow-db-convert](../workflow-db-convert/SKILL.md) — db track（DBオブジェクト）の変換手順
- [workflow-app-convert](../workflow-app-convert/SKILL.md) — app track（アプリケーションの埋め込みSQL）の変換手順
