# 関数の対応表: Oracle → PostgreSQL

関数単位の詳しい対応表。親: [../SKILL.md](../SKILL.md)。

SCT / DMS Schema Conversionの出力が`aws_oracle_ext.*`（AWS SCT拡張パック）の関数を使っている場合は、
書き換えずにそのまま使う（拡張パックの方針は[../SKILL.md](../SKILL.md)を参照）。

## NULLの扱い

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `NVL(a, b)` | `COALESCE(a, b)` | |
| `NVL2(a, b, c)` | `CASE WHEN a IS NOT NULL THEN b ELSE c END` | |
| `DECODE(expr, v1, r1, ..., def)` | `CASE expr WHEN v1 THEN r1 ... ELSE def END` | `DECODE`はNULL同士を一致とみなすが、`CASE`はみなさない。NULLを比べる場合は`IS NOT DISTINCT FROM`を使う |
| `NULLIF(a, b)` | `NULLIF(a, b)` | 同じ |
| `LNNVL(cond)` | `NOT (cond) OR cond IS NULL` | condがFALSEまたはNULLのときTRUE |
| `a \|\| b`（NULLになりうる列の連結） | `CONCAT(a, b)` | Oracleは連結でNULLを空文字として扱うが、PostgreSQLの`\|\|`は結果がNULLになる。`CONCAT`はNULLを無視するので、Oracleと同じ結果になる。すべてNULLのとき、Oracleは`NULL`、`CONCAT`は`''`を返すので、違いが問題になる場合は`NULLIF(CONCAT(...), '')`にする |

**必須**: 変換は、Oracleでの実行結果に合わせる。元のSQLの意図と結果が違うと思われる場合
（例: `NVL(a || ' ' || b, 'なし')`は、Oracleでは`' '`を返し、`'なし'`にならない）も、変換はOracleの結果に合わせ、
意図との違いは要確認として伝える。

## 文字列関数

**必須**: `REGEXP_SUBSTR`は`SUBSTRING(... FROM ...)`に変換する。出力に`REGEXP_SUBSTR`を残さない。

**必須**: `LISTAGG`は区切り文字でつないだ文字列を返す。`STRING_AGG(col, delimiter)`に変換する。`ARRAY_AGG`ではない（型の意味が異なる）。

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `SUBSTR(s, pos, len)` | `SUBSTRING(s FROM pos FOR len)` | |
| `SUBSTR(s, pos)` | `SUBSTRING(s FROM pos)` | |
| `INSTR(s, sub)` | `POSITION(sub IN s)` | 2引数の場合のみ。3〜4引数は`aws_oracle_ext.instr(s, sub, pos, occurrence)` |
| `CONCAT(a, b)` | `CONCAT(a, b)` | Oracleは2引数、PostgreSQLは任意の個数 |
| `LISTAGG(col, sep) WITHIN GROUP (ORDER BY ...)` | `STRING_AGG(col, sep ORDER BY ...)` | |
| `REGEXP_SUBSTR(s, pattern)` | `SUBSTRING(s FROM pattern)` | 必ず変換する |
| `REGEXP_REPLACE(s, pat, rep)` | `REGEXP_REPLACE(s, pat, rep)` | 同じ |
| `REGEXP_COUNT(s, pat)` | `array_length(regexp_matches(s, pat, 'g'), 1)` | 独自の関数が必要になることがある |
| `REGEXP_INSTR(s, pat)` | 独自の関数が必要 | 直接の対応なし |
| `LPAD`、`RPAD`、`LTRIM`、`RTRIM`、`TRIM` | 同じ | |
| `UPPER`、`LOWER`、`INITCAP` | 同じ | |
| `LENGTH(s)`、`LENGTHB(s)` | `LENGTH(s)`、`OCTET_LENGTH(s)` | |
| `TRANSLATE(s, from, to)` | `TRANSLATE(s, from, to)` | 同じ |
| `REPLACE(s, from, to)` | `REPLACE(s, from, to)` | 同じ |
| `ASCII(c)`、`CHR(n)` | 同じ | |
| `EMPTY_CLOB()` / `EMPTY_BLOB()` | `''::TEXT` / `''::BYTEA` | |

## 数値関数

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `ABS`、`CEIL`、`FLOOR`、`ROUND`、`MOD` | 同じ | |
| `TRUNC(number)` | `TRUNC(number)` | 同じ（数値の場合） |
| `TRUNC(number, n)` | `TRUNC(number, n)` | 同じ |
| `POWER(a, b)` | `POWER(a, b)` | 同じ |
| `SQRT(n)` | `SQRT(n)` | 同じ |
| `EXP`、`LN`、`LOG` | 同じ | |
| `SIGN`、`GREATEST`、`LEAST` | 同じ | |
| `ORA_HASH(expr)` | `hashtext(expr::TEXT)` | |
| `REMAINDER(a, b)` | `a - b * ROUND(a/b)` | 直接の対応なし |

## 日付・時刻関数

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `SYSDATE` | `aws_oracle_ext.sysdate()` | 拡張パック。`NOW()`や`CURRENT_TIMESTAMP`ではない（意味が異なる） |
| `SYSTIMESTAMP` | `aws_oracle_ext.systimestamp()` | 拡張パック |
| `CURRENT_DATE`、`CURRENT_TIMESTAMP` | 同じ | |
| `ADD_MONTHS(d, n)` | `d + INTERVAL 'n months'` | nが負の場合は`INTERVAL '-n months'`。拡張パックの`aws_oracle_ext.add_months(d, n)`もある |
| `MONTHS_BETWEEN(d1, d2)` | `aws_oracle_ext.months_between(d1, d2)` | 標準の関数で書くと誤差が出やすい |
| `TRUNC(date_col)` | `DATE_TRUNC('day', date_col)` | ⚠️ PostgreSQLの`TRUNC`は日付を受け付けない。必ず変換する |
| `TRUNC(date_col, 'MM')` | `DATE_TRUNC('month', date_col)` | 'YEAR'、'DAY'、'HH'、'MI'なども同様 |
| `TRUNC(date_col, 'YYYY')` | `DATE_TRUNC('year', date_col)` | |
| `TRUNC(numeric)` | `TRUNC(numeric)` | 数値の場合はそのまま |
| `TO_DATE(TO_CHAR(x, fmt), fmt)` | `x::date`または`DATE_TRUNC('day', x)` | ⚠️ 時刻を切り捨てる慣用句。簡潔に書き直す |
| `TO_DATE(s, fmt)` | `TO_TIMESTAMP(s, fmt)` | sが文字列の場合 |
| `TO_CHAR(d, fmt)` | `TO_CHAR(d, fmt)` | 書式コードを確認する（下記） |
| `LAST_DAY(d)` | `(DATE_TRUNC('month', d) + INTERVAL '1 month - 1 day')::DATE` | 拡張パックの`aws_oracle_ext.last_day(d)`もある |
| `NEXT_DAY(d, 'MONDAY')` | `aws_oracle_ext.next_day(d, 'MONDAY')` | 標準の関数には対応なし |
| `EXTRACT(YEAR FROM d)` | 同じ | |
| `TO_NUMBER(s)` | `CAST(s AS NUMERIC)` | 1引数の場合。2引数は書式付きの`TO_NUMBER`を使う |
| `NUMTODSINTERVAL(n, 'DAY')` | `n * INTERVAL '1 day'` | |

### 日付の書式コードの違い

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `RR` | `YY` | 2桁の年 |
| `SYYY` | `YYYY` | 符号付きの年 |
| `MON` | `Mon` | 大文字・小文字が異なることがある |
| `DY` | `Dy` | 大文字・小文字が異なることがある |
| `FMxx` | `FMxx` | 同じ（空白の抑制） |

## 環境・セッション関数

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `SYS_GUID()` | `gen_random_uuid()` | PostgreSQL 13以降。`SUBSTR`/`SUBSTRING`で囲む場合は先にキャストする: `SUBSTRING(gen_random_uuid()::text FROM ...)` |
| `SYS_CONTEXT('USERENV', <属性>)` | `aws_oracle_ext.sys_context('USERENV', <属性>)` | 拡張パック。`SESSION_USER`の場合だけは`current_user`でもよい |
| `USER` | `CURRENT_USER` | |
| `UID` | `(SELECT usesysid FROM pg_user WHERE usename = current_user)` | |
| `ROWNUM` | structural-conversions.mdを参照（使われ方で変わる） | |
| `FROM DUAL` | 削除 | PostgreSQLはFROM句のないSELECTを許す |
| `seq.NEXTVAL` | `nextval('seq')` | |
| `seq.CURRVAL` | `currval('seq')` | |

## 集計関数

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `LISTAGG(col, sep) WITHIN GROUP (ORDER BY ...)` | `STRING_AGG(col, sep ORDER BY ...)` | |
| `COUNT`、`SUM`、`AVG`、`MIN`、`MAX` | 同じ | |
| `STATS_*` | PostgreSQLの対応する関数を使う | PostgreSQLのドキュメントで確認する |
| `FIRST`、`LAST`（OracleのKEEP句） | ウィンドウ関数`FIRST_VALUE`、`LAST_VALUE`を使う | |

## 分析関数・ウィンドウ関数

OracleとPostgreSQLでほぼ互換。主な違い:

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `RATIO_TO_REPORT(x) OVER (...)` | `x / SUM(x) OVER (...)` | 直接の対応なし |
| `KEEP (DENSE_RANK ... ORDER BY ...)` | `FIRST_VALUE`/`LAST_VALUE`で書き直す | |

## 型変換関数

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `CAST(x AS TYPE)` | 同じ | |
| `TO_NUMBER(s)` | `CAST(s AS NUMERIC)` | 1引数の場合 |
| `TO_CHAR(x)` | `CAST(x AS TEXT)`または`TO_CHAR(x, fmt)` | |
| `TO_DATE(s, fmt)` | `TO_TIMESTAMP(s, fmt)` | |
| `HEX_TO_RAW(s)` | `decode(s, 'hex')` | |
| `RAW_TO_HEX(b)` | `encode(b, 'hex')` | |
