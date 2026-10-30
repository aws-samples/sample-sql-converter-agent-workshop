---
name: domain-conversion-rules
description: Reference card of Oracle to PostgreSQL SQL, DDL, function, and data type conversion rules. Use when looking up the PG equivalent of a specific Oracle construct (NVL, DECODE, SYSDATE, ROWNUM, CONNECT BY, LISTAGG, MERGE, (+) join, FROM DUAL, etc.), mapping data types (VARCHAR2, NUMBER, DATE, CLOB), or recalling PL/SQL → PL/pgSQL idiom differences. This skill is a lookup table — for orchestrating an actual conversion, use `workflow-db-convert` or `workflow-app-convert`.
---

# Oracle → PostgreSQL 変換ルール

Oracle SQL・DDL・PL/SQL構文をPostgreSQL相当に変換するための包括的な
マッピング表。対象はPostgreSQL 15以降（ワークショップ環境のAurora PostgreSQLは17.7）。

詳細は以下を参照:
- [references/function-mapping.md](./references/function-mapping.md) — NULL処理・文字列・数値・日付時刻・環境関数
- [references/structural-conversions.md](./references/structural-conversions.md) — JOIN、ROWNUM、CONNECT BY、PIVOT、MERGE、INSERT ALL、データディクショナリビュー
- [references/plsql-plpgsql.md](./references/plsql-plpgsql.md) — PL/SQLブロック、例外処理、カーソル、動的SQL、BULK COLLECT、型、DBリンク

## 基本的な変換方針

- 構文的に正しいPostgreSQL 15+のコードを出力する
- スキーマ/オブジェクト名は小文字に、SQLキーワードは大文字のまま保持する
- PL/SQLをPL/pgSQLに変換する
- 元のコメントを保持する
- **重要**: `REGEXP_SUBSTR`は必ず`SUBSTRING(... FROM ...)`に変換する。`REGEXP_SUBSTR`を出力に残してはならない。
- **重要**: `LISTAGG`は必ず`STRING_AGG(col, delimiter)`にする。`ARRAY_AGG`ではない（型の意味が異なる）。

## データ型マッピング

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| VARCHAR2(n) | VARCHAR(n) | |
| NVARCHAR2(n) | VARCHAR(n) | |
| NUMBER | NUMERIC | 精度指定なしでも可 |
| NUMBER(p,s) | NUMERIC(p,s) | |
| INTEGER | INTEGER | |
| DATE | TIMESTAMP | OracleのDATEは時刻部分を含む |
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
| ROWID | 非対応 | 主キーまたは`ctid`（不安定）を使用 |
| BFILE | 非対応 | アプリケーション層で対応 |

## よく使う関数変換（クイックリファレンス）

### NULL関数
| Oracle | PostgreSQL |
|---|---|
| `NVL(a, b)` | `COALESCE(a, b)` |
| `NVL2(a, b, c)` | `CASE WHEN a IS NOT NULL THEN b ELSE c END` |
| `DECODE(expr, v1, r1, ..., def)` | `CASE expr WHEN v1 THEN r1 ... ELSE def END` |

### 文字列関数（重要なもの）
| Oracle | PostgreSQL |
|---|---|
| `SUBSTR(s, pos, len)` | `SUBSTRING(s FROM pos FOR len)` |
| `INSTR(s, sub)` | `POSITION(sub IN s)`（2引数のみ） |
| `LISTAGG(col, sep) WITHIN GROUP (ORDER BY ...)` | `STRING_AGG(col, sep ORDER BY ...)` |
| `REGEXP_SUBSTR(s, pattern)` | `SUBSTRING(s FROM pattern)` |

### 日付時刻関数（重要なもの）
| Oracle | PostgreSQL |
|---|---|
| `SYSDATE` / `SYSTIMESTAMP` | `aws_oracle_ext.sysdate()`（AWS SCT拡張パック）— `NOW()`ではない |
| `TRUNC(date_col)` | `DATE_TRUNC('day', date_col)` ⚠️ PGの`TRUNC`は日付引数を受け付けない |
| `TRUNC(date_col, 'MM')` | `DATE_TRUNC('month', date_col)` |
| `ADD_MONTHS(d, n)` | `d + INTERVAL 'n months'` |

### 環境・セッション
| Oracle | PostgreSQL |
|---|---|
| `FROM DUAL` | 削除（PostgreSQLはFROM句なしのSELECTを許可） |
| `seq.NEXTVAL` | `nextval('seq')` |
| `seq.CURRVAL` | `currval('seq')` |
| `ROWNUM` | references/structural-conversions.mdのROWNUM節を参照 |
| `SYS_CONTEXT('USERENV', 'SESSION_USER')` | `aws_oracle_ext.sys_context('USERENV', 'SESSION_USER')`（このケースのみ`current_user`でも可） |
| `SYS_CONTEXT('USERENV', <any>)` | `aws_oracle_ext.sys_context('USERENV', <any>)` |

**関数マッピングの全表**: [references/function-mapping.md](./references/function-mapping.md)参照

## よく使う構造的変換（クイックリファレンス）

### 外部結合（Oracleの`(+)`記法 → PostgreSQL）

`(+)`条件をWHERE句からJOIN ON句に移動する。結合条件以外の条件はWHEREに残す。

```sql
-- Oracle
SELECT e.name, d.dept_name
FROM employees e, departments d
WHERE e.dept_id = d.dept_id(+) AND e.status = 'A'

-- PostgreSQL
SELECT e.name, d.dept_name
FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.status = 'A'
```

### 集合演算
| Oracle | PostgreSQL |
|---|---|
| `MINUS` | `EXCEPT` |
| `MINUS ALL` | `EXCEPT ALL` |

### ROWNUM → LIMIT / ウィンドウ関数

- トップレベルSELECTの`WHERE ROWNUM <= N` → `LIMIT N`
- `ROWNUM BETWEEN a AND b`によるページネーション → `ROW_NUMBER() OVER (...)`または`OFFSET/LIMIT`
- 複数行にわたるルールや複雑なパターン: [references/structural-conversions.md](./references/structural-conversions.md)参照

### MERGE文

`INSERT ... ON CONFLICT ... DO UPDATE SET ...`に変換する。詳細と例は[references/structural-conversions.md](./references/structural-conversions.md)参照。

### CONNECT BY（階層クエリ）

`WITH RECURSIVE`に変換する。完全なテンプレートと例は[references/structural-conversions.md](./references/structural-conversions.md)参照。

### INSERT ALL

複数の`INSERT`文に分割する。条件付きバリアントは`WITH`+`INSERT ... WHERE`を使う。

### PIVOT / UNPIVOT

PIVOTには条件付き集計（`MAX(CASE WHEN ... THEN ... END)`）を使う。UNPIVOTには`UNION ALL`または`LATERAL`を使う。

### オプティマイザヒント

Oracleヒント（`/*+ ... */`）は全て削除する。PostgreSQLには相当するヒント構文がない。

### データディクショナリビュー

`USER_TABLES`、`ALL_TABLES`、`DBA_TABLES`を`information_schema.tables`または`pg_catalog.pg_tables`に変換する。完全なマッピングは[references/structural-conversions.md](./references/structural-conversions.md)参照。

## PL/SQL → PL/pgSQL（概要）

PostgreSQLはPL/pgSQLをサポートしており、PL/SQLと概念は共通するが構文・挙動が異なる:

- PostgreSQLの関数内では**トランザクション制御は使用不可**。COMMIT/ROLLBACKが必要な場合はPROCEDURE（PostgreSQL 11+）+`CALL`を使う。
- PL/pgSQLでは**ネストした関数定義は不可**。内部関数は独立した関数として定義する。
- 例外処理、カーソル属性、動的SQL、BULK COLLECT、型、オブジェクト型は構文が異なる。

**PL/SQL変換の詳細**: [references/plsql-plpgsql.md](./references/plsql-plpgsql.md)参照

## 分類のヒント

これらのルールを適用する際は、変換難易度の分類（A/B/C、`tool-app-inventory-schema`/`tool-db-inventory-schema`のReview Status語彙参照）と組み合わせる:

- **分類A**（機械的に自動変換可能）: NVL→COALESCE、SYSDATE→sysdate()、FROM DUAL削除、SUBSTR→SUBSTRING、ROWNUM→LIMIT（単純なケース）
- **分類B**（レビュー推奨、構造的）: MERGE→INSERT ON CONFLICT、INSERT ALL→分割、`(+)`→LEFT JOIN、MINUS→EXCEPT
- **分類C**（手動対応、設計判断が必要）: CONNECT BY→WITH RECURSIVE、PIVOT→条件付き集計、複雑なROWNUMパターン、データディクショナリビュー

## 検証

変換後は必ずMCPツール`validate_pg_sql`を呼び、Oracle構文の残留を検出する。報告されたissueは、変換完了とみなす前に対応すること。

## Related skills

- [workflow-db-convert](../workflow-db-convert/SKILL.md) — db trackオブジェクトの変換ワークフロー
- [workflow-app-convert](../workflow-app-convert/SKILL.md) — app track埋め込みSQLの変換ワークフロー
- [tool-db-inventory-schema](../tool-db-inventory-schema/SKILL.md) — db trackのreview status語彙
- [tool-app-inventory-schema](../tool-app-inventory-schema/SKILL.md) — app trackのreview status語彙・Classification
