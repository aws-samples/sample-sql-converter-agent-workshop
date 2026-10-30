# Function Mapping: Oracle to PostgreSQL

Detailed function-level mapping. Parent: [../SKILL.md](../SKILL.md).

## Null Functions

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `NVL(a, b)` | `COALESCE(a, b)` | |
| `NVL2(a, b, c)` | `CASE WHEN a IS NOT NULL THEN b ELSE c END` | |
| `DECODE(expr, v1, r1, ..., def)` | `CASE expr WHEN v1 THEN r1 ... ELSE def END` | |
| `NULLIF(a, b)` | `NULLIF(a, b)` | Same |
| `LNNVL(cond)` | `NOT (cond) OR cond IS NULL` | Returns TRUE when cond is FALSE or NULL |

## String Functions

**CRITICAL**: `REGEXP_SUBSTR` MUST be converted to `SUBSTRING(... FROM ...)`. Do NOT leave `REGEXP_SUBSTR` in output.

**CRITICAL**: `LISTAGG` aggregates values into a delimited STRING. MUST become `STRING_AGG(col, delimiter)`, NOT `ARRAY_AGG` (different type semantics).

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `SUBSTR(s, pos, len)` | `SUBSTRING(s FROM pos FOR len)` | |
| `SUBSTR(s, pos)` | `SUBSTRING(s FROM pos)` | |
| `INSTR(s, sub)` | `POSITION(sub IN s)` | 2-arg only |
| `CONCAT(a, b)` | `CONCAT(a, b)` | Oracle takes 2 args; PostgreSQL takes many |
| `LISTAGG(col, sep) WITHIN GROUP (ORDER BY ...)` | `STRING_AGG(col, sep ORDER BY ...)` | |
| `REGEXP_SUBSTR(s, pattern)` | `SUBSTRING(s FROM pattern)` | Must convert |
| `REGEXP_REPLACE(s, pat, rep)` | `REGEXP_REPLACE(s, pat, rep)` | Same |
| `REGEXP_COUNT(s, pat)` | `array_length(regexp_matches(s, pat, 'g'), 1)` | Custom function may be needed |
| `REGEXP_INSTR(s, pat)` | Custom function needed | No direct equivalent |
| `LPAD`, `RPAD`, `LTRIM`, `RTRIM`, `TRIM` | Same | |
| `UPPER`, `LOWER`, `INITCAP` | Same | |
| `LENGTH(s)`, `LENGTHB(s)` | `LENGTH(s)`, `OCTET_LENGTH(s)` | |
| `TRANSLATE(s, from, to)` | `TRANSLATE(s, from, to)` | Same |
| `REPLACE(s, from, to)` | `REPLACE(s, from, to)` | Same |
| `ASCII(c)`, `CHR(n)` | Same | |
| `EMPTY_CLOB()` / `EMPTY_BLOB()` | `''::TEXT` / `''::BYTEA` | |

## Numeric Functions

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `ABS`, `CEIL`, `FLOOR`, `ROUND`, `MOD` | Same | |
| `TRUNC(number)` | `TRUNC(number)` | Same (numeric form) |
| `TRUNC(number, n)` | `TRUNC(number, n)` | Same |
| `POWER(a, b)` | `POWER(a, b)` | Same |
| `SQRT(n)` | `SQRT(n)` | Same |
| `EXP`, `LN`, `LOG` | Same | |
| `SIGN`, `GREATEST`, `LEAST` | Same | |
| `ORA_HASH(expr)` | `hashtext(expr::TEXT)` | |
| `REMAINDER(a, b)` | `a - b * ROUND(a/b)` | No direct equivalent |

## Date/Time Functions

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `SYSDATE` | `aws_oracle_ext.sysdate()` | AWS SCT extension pack — NOT `NOW()` or `CURRENT_TIMESTAMP` |
| `SYSTIMESTAMP` | `aws_oracle_ext.sysdate()` | AWS SCT extension pack |
| `CURRENT_DATE`, `CURRENT_TIMESTAMP` | Same | |
| `ADD_MONTHS(d, n)` | `d + INTERVAL 'n months'` | Negative n: `INTERVAL '-n months'` |
| `MONTHS_BETWEEN(d1, d2)` | `EXTRACT(EPOCH FROM age(d1, d2)) / 2592000` | |
| `TRUNC(date_col)` | `DATE_TRUNC('day', date_col)` | ⚠️ PG `TRUNC` rejects date args — MUST convert |
| `TRUNC(date_col, 'MM')` | `DATE_TRUNC('month', date_col)` | Also 'YEAR', 'DAY', 'HH', 'MI' etc. |
| `TRUNC(date_col, 'YYYY')` | `DATE_TRUNC('year', date_col)` | |
| `TRUNC(numeric)` | `TRUNC(numeric)` | Numeric form — keep as-is |
| `TO_DATE(TO_CHAR(x, fmt), fmt)` | `x::date` or `DATE_TRUNC('day', x)` | ⚠️ Time-stripping idiom — simplify |
| `TO_DATE(s, fmt)` | `TO_TIMESTAMP(s, fmt)` | When s is a string |
| `TO_CHAR(d, fmt)` | `TO_CHAR(d, fmt)` | Verify format codes — see below |
| `LAST_DAY(d)` | `(DATE_TRUNC('month', d) + INTERVAL '1 month - 1 day')::DATE` | |
| `NEXT_DAY(d, 'MONDAY')` | Custom function needed | |
| `EXTRACT(YEAR FROM d)` | Same | |
| `TO_NUMBER(s)` | `CAST(s AS NUMERIC)` | 1-arg only; 2-arg needs TO_NUMBER with format |
| `NUMTODSINTERVAL(n, 'DAY')` | `n * INTERVAL '1 day'` | |

### Date Format Code Differences

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `RR` | `YY` | 2-digit year |
| `SYYY` | `YYYY` | Signed year |
| `MON` | `Mon` | Case may differ |
| `DY` | `Dy` | Case may differ |
| `FMxx` | `FMxx` | Same (fill-mode suppression) |

## Environment / Session Functions

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `SYS_GUID()` | `gen_random_uuid()` | PostgreSQL 13+. When wrapped in `SUBSTR`/`SUBSTRING`, cast first: `SUBSTRING(gen_random_uuid()::text FROM ...)` |
| `SYS_CONTEXT('USERENV', 'SESSION_USER')` | `current_user` | |
| `SYS_CONTEXT('USERENV', 'SESSIONID')` | `current_setting('application_name')` | Approximate |
| `SYS_CONTEXT('USERENV', param)` | `current_setting(param)` | Other params |
| `USER` | `CURRENT_USER` | |
| `UID` | `(SELECT usesysid FROM pg_user WHERE usename = current_user)` | |
| `ROWNUM` | See structural-conversions.md — context-dependent | |
| `FROM DUAL` | Remove | PostgreSQL allows SELECT without FROM |
| `seq.NEXTVAL` | `nextval('seq')` | |
| `seq.CURRVAL` | `currval('seq')` | |

## Aggregate Functions

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `LISTAGG(col, sep) WITHIN GROUP (ORDER BY ...)` | `STRING_AGG(col, sep ORDER BY ...)` | |
| `COUNT`, `SUM`, `AVG`, `MIN`, `MAX` | Same | |
| `STATS_*` | Various; use PostgreSQL-specific equivalents | Check pg docs |
| `FIRST`, `LAST` (Oracle KEEP clause) | Use window functions `FIRST_VALUE`, `LAST_VALUE` | |

## Analytic / Window Functions

Mostly compatible between Oracle and PostgreSQL. Key differences:

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `RATIO_TO_REPORT(x) OVER (...)` | `x / SUM(x) OVER (...)` | No direct equivalent |
| `KEEP (DENSE_RANK ... ORDER BY ...)` | Rewrite using `FIRST_VALUE`/`LAST_VALUE` with `IGNORE NULLS` | |

## Type Conversion Functions

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `CAST(x AS TYPE)` | Same | |
| `TO_NUMBER(s)` | `CAST(s AS NUMERIC)` | 1-arg |
| `TO_CHAR(x)` | `CAST(x AS TEXT)` or `TO_CHAR(x, fmt)` | |
| `TO_DATE(s, fmt)` | `TO_TIMESTAMP(s, fmt)` | |
| `HEX_TO_RAW(s)` | `decode(s, 'hex')` | |
| `RAW_TO_HEX(b)` | `encode(b, 'hex')` | |
