# Structural Conversions: Oracle to PostgreSQL

Structural SQL patterns that require rewriting (not simple function replacement). Parent: [../SKILL.md](../SKILL.md).

## Joins (Oracle `(+)` notation)

`(+)` outer join requires structural rewrite of FROM and WHERE clauses. Move the `(+)` condition from WHERE to the JOIN ON clause. Keep non-join conditions in WHERE.

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

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `t1, t2 WHERE t1.col = t2.col(+)` | `t1 LEFT JOIN t2 ON t1.col = t2.col` | |
| `t1, t2 WHERE t1.col(+) = t2.col` | `t1 RIGHT JOIN t2 ON t1.col = t2.col` | |
| `INNER JOIN` | `JOIN` | Use `JOIN` not `INNER JOIN` |
| `NATURAL JOIN`, `USING(col)` | Same | |

## Set Operations

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `UNION` | `UNION` | Same |
| `UNION ALL` | `UNION ALL` | Same |
| `INTERSECT` | `INTERSECT` | Same |
| `MINUS` | `EXCEPT` | Must convert |
| `MINUS ALL` | `EXCEPT ALL` | Must convert |

## ROWNUM

`ROWNUM` is context-dependent. Use appropriate PostgreSQL construct based on usage pattern:

### Pattern 1: Limit rows
```sql
-- Oracle
SELECT * FROM t WHERE ROWNUM <= 10

-- PostgreSQL
SELECT * FROM t LIMIT 10
```

### Pattern 2: Pagination (nested subquery)
```sql
-- Oracle
SELECT * FROM (
  SELECT t.*, ROWNUM rn FROM (SELECT * FROM t ORDER BY id) t WHERE ROWNUM <= 20
) WHERE rn > 10

-- PostgreSQL
SELECT * FROM t ORDER BY id OFFSET 10 LIMIT 10
```

### Pattern 3: Row numbering in output
```sql
-- Oracle
SELECT ROWNUM, t.* FROM t

-- PostgreSQL
SELECT ROW_NUMBER() OVER () AS rn, t.* FROM t
```

### Pattern 4: ROWNUM with ORDER BY (Oracle gotcha)

Oracle applies ROWNUM before ORDER BY; PostgreSQL ORDER BY + LIMIT is intuitive. Verify semantics when converting.

## Hierarchical Queries (CONNECT BY → WITH RECURSIVE)

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
  WHERE manager_id IS NULL          -- START WITH condition
  UNION ALL
  SELECT e.employee_id, e.manager_id, e.name, h.level + 1
  FROM employees e
  JOIN hier h ON e.manager_id = h.employee_id   -- CONNECT BY PRIOR ... = ...
)
SELECT * FROM hier
```

### CONNECT BY Pseudo-columns

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `LEVEL` | Manual: increment in recursive CTE | |
| `SYS_CONNECT_BY_PATH(col, sep)` | Build path in recursive CTE: `parent.path || sep || child.col` | |
| `CONNECT_BY_ROOT col` | Track root in recursive CTE | |
| `CONNECT_BY_ISLEAF` | NOT EXISTS subquery or post-processing | |

## PIVOT / UNPIVOT

### PIVOT → Conditional Aggregation

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

### UNPIVOT → UNION ALL or LATERAL

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

Complex MERGE with `WHEN MATCHED THEN DELETE` or multiple conditions may require CTEs and multiple statements.

## FOR UPDATE Lock Clauses

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `FOR UPDATE` | `FOR UPDATE` | Same |
| `FOR UPDATE NOWAIT` | `FOR UPDATE NOWAIT` | Same |
| `FOR UPDATE SKIP LOCKED` | `FOR UPDATE SKIP LOCKED` | Same (9.5+) |
| `FOR UPDATE OF col` | `FOR UPDATE OF table` | PG specifies table, not column |

## NULL Ordering

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `ORDER BY col NULLS FIRST` | Same | |
| `ORDER BY col NULLS LAST` | Same | |

Default behavior: Oracle puts NULLs last (ASC) / first (DESC); PostgreSQL same.

## INSERT ALL

### Unconditional INSERT ALL → Multiple INSERTs

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

### Conditional INSERT ALL → CTE + multiple INSERT ... WHERE

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

## Optimizer Hints

Remove all Oracle hints. PostgreSQL has no equivalent hint syntax.

| Oracle | PostgreSQL |
|---|---|
| `/*+ INDEX(t idx) */` | Remove |
| `/*+ FIRST_ROWS */`, `/*+ ALL_ROWS */` | Remove |
| `/*+ PARALLEL(t, 4) */` | Remove |
| `/*+ USE_NL */`, `/*+ USE_HASH */` | Remove |

Optionally use PostgreSQL session settings (`SET enable_nestloop = off`) or `pg_hint_plan` extension if absolutely needed.

## Data Dictionary Views

| Oracle | PostgreSQL | Notes |
|---|---|---|
| `USER_TABLES`, `ALL_TABLES`, `DBA_TABLES` | `information_schema.tables` or `pg_catalog.pg_tables` | |
| `USER_TAB_COLUMNS` | `information_schema.columns` | |
| `USER_INDEXES` | `pg_catalog.pg_indexes` | |
| `USER_CONSTRAINTS` | `information_schema.table_constraints` | |
| `USER_SEQUENCES` | `information_schema.sequences` | |
| `USER_VIEWS` | `information_schema.views` | |
| `V$SESSION` | `pg_stat_activity` | |
| `V$SQL` | `pg_stat_statements` (requires extension) | |

## Synonyms

PostgreSQL does not have synonyms. Alternatives:

- **Views**: `CREATE VIEW schema.alias AS SELECT * FROM other_schema.real_name;`
- **Search path**: `SET search_path TO schema1, schema2;`
- **Cross-schema references**: Use fully qualified names `schema.table`

## Database Links

PostgreSQL has no `DATABASE LINK`. Use:

- **postgres_fdw** (foreign data wrapper) for PostgreSQL-to-PostgreSQL
- **oracle_fdw** for PostgreSQL-to-Oracle
- **dblink** extension for legacy-style links

## External Tables

| Oracle | PostgreSQL | Notes |
|---|---|---|
| External tables | `file_fdw` extension + `COPY` | Requires FDW setup |

## Materialized View Logs

Oracle `CREATE MATERIALIZED VIEW LOG` has no direct PostgreSQL equivalent. Use triggers + audit tables or CDC tools (Debezium, etc.).
