# PL/SQL to PL/pgSQL Conversion

PL/SQL to PostgreSQL PL/pgSQL conversion rules. Parent: [../SKILL.md](../SKILL.md).

Primary target: database objects (DDL, stored procedures, functions, packages). Many rules also apply to anonymous PL/SQL blocks.

## Basic Principles

- Convert PL/SQL syntax to PL/pgSQL syntax appropriately
- Preserve comments from original code
- **Transaction control (COMMIT, ROLLBACK) is NOT allowed inside PostgreSQL FUNCTIONS**. Use PROCEDURE (PostgreSQL 11+) with `CALL` if transaction control is required, or remove transaction control and add comment: "Transaction control must be implemented in the calling code".
- **Nested function definitions are NOT supported**. Define inner functions as separate standalone functions and call them from the main procedure.

## FUNCTION vs PROCEDURE

| Need | Use in PostgreSQL |
|---|---|
| Return value | FUNCTION |
| Side effects only, no return | FUNCTION returning `void` (simple case) or PROCEDURE |
| COMMIT/ROLLBACK inside | PROCEDURE (11+), invoked with `CALL` |
| Pipelined (row-by-row streaming) | FUNCTION returning SETOF / TABLE |
| OUT parameters | Both support, but PROCEDURE supports them more naturally in 14+ |

## Exception Handling

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `EXCEPTION WHEN NO_DATA_FOUND THEN ...` | `EXCEPTION WHEN NO_DATA_FOUND THEN ...` | Same |
| `EXCEPTION WHEN OTHERS THEN ...` | `EXCEPTION WHEN OTHERS THEN ...` | Same |
| `EXCEPTION WHEN DUP_VAL_ON_INDEX THEN ...` | `EXCEPTION WHEN unique_violation THEN ...` | Different name |
| `RAISE_APPLICATION_ERROR(-20001, 'msg')` | `RAISE EXCEPTION 'msg' USING ERRCODE = '20001'` | |
| `SQLCODE`, `SQLERRM` | `SQLSTATE`, `SQLERRM` | SQLSTATE is 5-char code |
| Named user exception | Declare and raise custom exception | |

Example:

```sql
-- Oracle
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20001, 'Not found');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;

-- PostgreSQL
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE EXCEPTION 'Not found' USING ERRCODE = '20001';
  WHEN OTHERS THEN
    -- Transaction control must be implemented in the calling code
    RAISE;
```

## Cursor Attributes

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `cursor%FOUND` | `FOUND` | After FETCH |
| `cursor%NOTFOUND` | `NOT FOUND` | After FETCH |
| `cursor%ROWCOUNT` | `GET DIAGNOSTICS n = ROW_COUNT` | |
| `cursor%ISOPEN` | Not directly available; use boolean flag | |

```sql
-- Oracle
OPEN cur;
LOOP
  FETCH cur INTO r;
  EXIT WHEN cur%NOTFOUND;
  -- process
END LOOP;
CLOSE cur;

-- PostgreSQL
OPEN cur;
LOOP
  FETCH cur INTO r;
  EXIT WHEN NOT FOUND;
  -- process
END LOOP;
CLOSE cur;
```

## Dynamic SQL

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `EXECUTE IMMEDIATE 'stmt'` | `EXECUTE 'stmt'` | |
| `EXECUTE IMMEDIATE stmt INTO var` | `EXECUTE stmt INTO var` | |
| `EXECUTE IMMEDIATE stmt USING a, b` | `EXECUTE stmt USING a, b` | |
| `DBMS_SQL.*` (explicit cursor) | `EXECUTE` with `USING` or procedures | |

## FORALL / BULK COLLECT

PostgreSQL does not have FORALL / BULK COLLECT. Alternatives:

| Oracle | PostgreSQL |
|---|---|
| `FORALL i IN ... INSERT` | Single `INSERT INTO t SELECT ...` or `INSERT ... FROM unnest(array)` |
| `BULK COLLECT INTO array` | `SELECT array_agg(...)` or query returning SETOF |

```sql
-- Oracle
FORALL i IN 1..ids.COUNT
  INSERT INTO t VALUES (ids(i), names(i));

-- PostgreSQL
INSERT INTO t (id, name)
SELECT * FROM unnest(ids, names);
```

## TYPE / RECORD Conversion

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `TYPE rec IS RECORD (...)` | `CREATE TYPE rec AS (...)` or local record variable | |
| `TYPE arr IS TABLE OF type` (nested table) | `ARRAY` type or composite TABLE | |
| `TYPE arr IS TABLE OF type INDEX BY BINARY_INTEGER` (associative array / PL/SQL table) | Use `hstore` extension or `jsonb` for key-value | |
| `TYPE arr IS VARRAY(N) OF type` | `type[]` (PostgreSQL arrays are unbounded) | |

## Object Types with Methods

Oracle object types with methods (`CREATE TYPE ... AS OBJECT ... MEMBER FUNCTION ...`) have no direct PostgreSQL equivalent. Options:

- **Composite TYPE** + separate functions operating on the type
- **JSONB** for semi-structured data
- **Application-level objects** (move logic out of DB)

## Return Value Handling

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `RETURN value` (in FUNCTION) | `RETURN value` | Same |
| `RETURN QUERY SELECT ...` | `RETURN QUERY SELECT ...` | Same (SETOF-returning functions) |
| `PIPE ROW(rec)` (pipelined functions) | `RETURN NEXT rec` in SETOF-returning function | |
| `PIPELINED` keyword | `RETURNS SETOF ...` or `RETURNS TABLE (...)` | |

## CONNECT BY in PL/SQL

See [structural-conversions.md](./structural-conversions.md#hierarchical-queries-connect-by--with-recursive). Same rules apply within PL/pgSQL blocks.

## File Operations (Oracle UTL packages)

Oracle built-in packages have no direct PostgreSQL equivalents. Conversion strategies:

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `UTL_FILE` (file I/O) | `COPY` command, `pg_read_file()`, or application-layer file handling | Server-side `COPY` requires superuser |
| `UTL_HTTP` (HTTP calls) | `http` extension or application-layer | |
| `UTL_SMTP` (email) | Application-layer | |
| `DBMS_SCHEDULER` | `pg_cron` extension or external scheduler (cron, Airflow) | |
| `DBMS_LOB` (LOB manipulation) | Use `TEXT`/`BYTEA` operators directly, or `pg_largeobject` for very large data | |
| `DBMS_OUTPUT.PUT_LINE` | `RAISE NOTICE '...'` | Visible when client has notice level enabled |
| `DBMS_RANDOM.VALUE` | `random()` | |

## Numeric Precision

Be careful when converting `NUMBER` to `NUMERIC`:

- `NUMBER` without precision in Oracle allows any magnitude; `NUMERIC` without precision in PostgreSQL is similar but has implementation differences
- Use explicit precision when possible: `NUMBER(10,2)` → `NUMERIC(10,2)`
- Action Item reference: some migrations require explicit precision for financial calculations

## Synonyms, Database Links, External Tables

See [structural-conversions.md](./structural-conversions.md#synonyms) — same content applies to PL/SQL DDL.
