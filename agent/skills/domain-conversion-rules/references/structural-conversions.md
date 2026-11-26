# 構造の変換: Oracle → PostgreSQL

関数の置き換えだけでは済まず、構造の書き直しが必要なSQLのパターン。親: [../SKILL.md](../SKILL.md)。

## 結合（Oracleの`(+)`記法）

`(+)`による外部結合は、FROM句とWHERE句の書き直しが必要。`(+)`の条件をWHERE句からJOINのON句に移す。結合条件以外の条件はWHEREに残す。

```sql
-- Oracle
SELECT e.name, d.dept_name
FROM employees e, departments d
WHERE e.dept_id = d.dept_id(+)
AND e.status = 'A'

-- PostgreSQL
SELECT e.name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.status = 'A'
```

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `t1, t2 WHERE t1.col = t2.col(+)` | `t1 LEFT JOIN t2 ON t1.col = t2.col` | |
| `t1, t2 WHERE t1.col(+) = t2.col` | `t1 RIGHT JOIN t2 ON t1.col = t2.col` | |
| `INNER JOIN` | `JOIN` | `INNER JOIN`ではなく`JOIN`と書く |
| `NATURAL JOIN`、`USING(col)` | 同じ | |

## 集合演算

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `UNION` | `UNION` | 同じ |
| `UNION ALL` | `UNION ALL` | 同じ |
| `INTERSECT` | `INTERSECT` | 同じ |
| `MINUS` | `EXCEPT` | 必ず変換する |
| `MINUS ALL` | `EXCEPT ALL` | 必ず変換する |

## ROWNUM

`ROWNUM`は使われ方によって変換先が変わる。使い方のパターンに合わせて選ぶ。

### パターン1: 行数の制限
```sql
-- Oracle
SELECT * FROM t WHERE ROWNUM <= 10

-- PostgreSQL
SELECT * FROM t LIMIT 10
```

### パターン2: ページング（ネストしたサブクエリ）
```sql
-- Oracle
SELECT * FROM (
  SELECT t.*, ROWNUM rn FROM (SELECT * FROM t ORDER BY id) t WHERE ROWNUM <= 20
) WHERE rn > 10

-- PostgreSQL
SELECT * FROM t ORDER BY id OFFSET 10 LIMIT 10
```

アプリケーションのSQLでページングの位置がバインド変数になっている場合は、バインド変数の個数が変わらない書き方にする（`workflow-app-convert`のバインド変数の整合性を参照）。

### パターン3: 出力に行番号を付ける
```sql
-- Oracle
SELECT ROWNUM, t.* FROM t

-- PostgreSQL
SELECT ROW_NUMBER() OVER () AS rn, t.* FROM t
```

### パターン4: ROWNUMとORDER BY（Oracleの落とし穴）

OracleはORDER BYの前にROWNUMを付ける。PostgreSQLのORDER BY + LIMITは見たとおりの順序になる。変換するときに意味が変わらないか確かめる。

## 階層クエリ（CONNECT BY → WITH RECURSIVE）

```sql
-- Oracle
SELECT employee_id, manager_id, name, LEVEL
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id

-- PostgreSQL
WITH RECURSIVE hier AS (
  SELECT employee_id, manager_id, name, 1 AS level
  FROM employees
  WHERE manager_id IS NULL          -- START WITHの条件
  UNION ALL
  SELECT e.employee_id, e.manager_id, e.name, h.level + 1
  FROM employees e
  JOIN hier h ON e.manager_id = h.employee_id   -- CONNECT BY PRIOR ... = ...
)
SELECT * FROM hier
```

### CONNECT BYの疑似列

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `LEVEL` | 再帰CTEの中で自分で1ずつ増やす | |
| `SYS_CONNECT_BY_PATH(col, sep)` | 再帰CTEの中でパスを組み立てる: `parent.path || sep || child.col` | |
| `CONNECT_BY_ROOT col` | 再帰CTEの中で根の値を持ち回る | |
| `CONNECT_BY_ISLEAF` | NOT EXISTSのサブクエリ、または後処理 | |

## PIVOT / UNPIVOT

### PIVOT → 条件付きの集計

```sql
-- Oracle
SELECT * FROM sales PIVOT (SUM(amount) FOR quarter IN ('Q1', 'Q2', 'Q3', 'Q4'))

-- PostgreSQL
SELECT
  SUM(CASE WHEN quarter = 'Q1' THEN amount END) AS "Q1",
  SUM(CASE WHEN quarter = 'Q2' THEN amount END) AS "Q2",
  SUM(CASE WHEN quarter = 'Q3' THEN amount END) AS "Q3",
  SUM(CASE WHEN quarter = 'Q4' THEN amount END) AS "Q4"
FROM sales
```

### UNPIVOT → UNION ALLまたはLATERAL

```sql
-- Oracle
SELECT * FROM quarters UNPIVOT (amount FOR quarter IN (Q1, Q2, Q3, Q4))

-- PostgreSQL
SELECT id, 'Q1' AS quarter, Q1 AS amount FROM quarters
UNION ALL SELECT id, 'Q2', Q2 FROM quarters
UNION ALL SELECT id, 'Q3', Q3 FROM quarters
UNION ALL SELECT id, 'Q4', Q4 FROM quarters
```

## MERGE → INSERT ON CONFLICT

```sql
-- Oracle
MERGE INTO target t USING source s ON (t.id = s.id)
WHEN MATCHED THEN UPDATE SET t.val = s.val
WHEN NOT MATCHED THEN INSERT (id, val) VALUES (s.id, s.val)

-- PostgreSQL
INSERT INTO target (id, val)
SELECT s.id, s.val FROM source s
ON CONFLICT (id) DO UPDATE SET val = EXCLUDED.val
```

`WHEN MATCHED THEN DELETE`や複数の条件を持つ複雑なMERGEは、CTEと複数の文に分ける必要があることがある。PostgreSQL 15以降は`MERGE`文も使える。

## FOR UPDATEによるロック

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `FOR UPDATE` | `FOR UPDATE` | 同じ |
| `FOR UPDATE NOWAIT` | `FOR UPDATE NOWAIT` | 同じ |
| `FOR UPDATE SKIP LOCKED` | `FOR UPDATE SKIP LOCKED` | 同じ（9.5以降） |
| `FOR UPDATE OF col` | `FOR UPDATE OF table` | PostgreSQLは列ではなく表を指定する |

## NULLの並び順

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `ORDER BY col NULLS FIRST` | 同じ | |
| `ORDER BY col NULLS LAST` | 同じ | |

既定の動作: OracleもPostgreSQLも、昇順ではNULLが最後、降順では最初。

## INSERT ALL

### 条件なしのINSERT ALL → 複数のINSERT

```sql
-- Oracle
INSERT ALL
  INTO t1 VALUES (1, 'a')
  INTO t2 VALUES (2, 'b')
SELECT * FROM dual

-- PostgreSQL
INSERT INTO t1 VALUES (1, 'a');
INSERT INTO t2 VALUES (2, 'b');
```

### 条件付きのINSERT ALL → CTE + 複数のINSERT ... WHERE

```sql
-- Oracle
INSERT ALL
  WHEN val > 100 THEN INTO big_values VALUES (val)
  WHEN val <= 100 THEN INTO small_values VALUES (val)
SELECT val FROM source

-- PostgreSQL
WITH src AS (SELECT val FROM source)
INSERT INTO big_values SELECT val FROM src WHERE val > 100;

WITH src AS (SELECT val FROM source)
INSERT INTO small_values SELECT val FROM src WHERE val <= 100;
```

## オプティマイザヒント

Oracleのヒントはすべて削除する。PostgreSQLには同じヒントの構文がない。

| Oracle | PostgreSQL |
|---|---|
| `/*+ INDEX(t idx) */` | 削除 |
| `/*+ FIRST_ROWS */`、`/*+ ALL_ROWS */` | 削除 |
| `/*+ PARALLEL(t, 4) */` | 削除 |
| `/*+ USE_NL */`、`/*+ USE_HASH */` | 削除 |

どうしても必要な場合は、PostgreSQLのセッション設定（`SET enable_nestloop = off`）や`pg_hint_plan`拡張を使う。

## データディクショナリビュー

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `USER_TABLES`、`ALL_TABLES`、`DBA_TABLES` | `information_schema.tables`または`pg_catalog.pg_tables` | |
| `USER_TAB_COLUMNS` | `information_schema.columns` | |
| `USER_INDEXES` | `pg_catalog.pg_indexes` | |
| `USER_CONSTRAINTS` | `information_schema.table_constraints` | |
| `USER_SEQUENCES` | `information_schema.sequences` | |
| `USER_VIEWS` | `information_schema.views` | |
| `V$SESSION` | `pg_stat_activity` | |
| `V$SQL` | `pg_stat_statements`（拡張が必要） | |

## シノニム

PostgreSQLにはシノニムがない。代わりの方法:

- **ビュー**: `CREATE VIEW schema.alias AS SELECT * FROM other_schema.real_name;`
- **検索パス**: `SET search_path TO schema1, schema2;`
- **スキーマをまたぐ参照**: `schema.table`のように完全な名前で書く

## データベースリンク

PostgreSQLには`DATABASE LINK`がない。移行後に参照先がどこにあるかで、代わりの方法が変わる:

| 移行後の参照先 | 代わりの方法 |
|---|---|
| 同じデータベース（参照先の表も同じAurora PostgreSQLに移行する） | ビュー、またはスキーマ名付きの参照（`schema.table`）。FDWは不要 |
| 別のPostgreSQL | **postgres_fdw**（`CREATE SERVER` / `CREATE USER MAPPING` / 外部テーブル） |
| Oracleに残る | **oracle_fdw**（Aurora PostgreSQL 12.7以降で使える） |
| 従来のリンクに近い書き方をしたい | **dblink** 拡張 |

- postgres_fdwの接続先はPostgreSQLだけで、Oracleには接続できない。参照先がOracleに残る場合に、postgres_fdwと書かない
  （コメント、OK.txt / NG.txt、ユーザーへの説明も含めて、oracle_fdwと書く）。
- DMS SCは、DB LINKをpostgres_fdwの外部サーバーとユーザーマッピングに変換する。参照先がOracleに残る場合は、
  そのままでは動かないため、oracle_fdwに置き換える。
- 接続先のパスワードは、`CREATE USER MAPPING`に直接書かない。プレースホルダーにして、設定の手順を注意事項に書く。

## 外部表

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| 外部表（`ORGANIZATION EXTERNAL`、`ORACLE_LOADER`） | 通常の表 + `aws_s3.table_import_from_s3`（ファイルをS3に置いて取り込む） | Aurora PostgreSQLでは`file_fdw`拡張を使えない。取り込みのタイミング（都度か定期か）は運用の設計が必要 |

## マテリアライズドビューのログ

Oracleの`CREATE MATERIALIZED VIEW LOG`には、PostgreSQLに直接の対応がない。トリガーと監査用の表、またはCDCツール（Debeziumなど）を使う。
