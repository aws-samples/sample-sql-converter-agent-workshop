"""Constants used by the validator.

Kept in a private module so they are re-usable by tests and the residual
detector without exposing them on the MCP interface.
"""

# Additional residual features flagged ONLY during post-conversion validation.
# Context-dependent during assessment (classified by LLM) or conversion artifacts.
VALIDATOR_EXTRA_FEATURES = [
    ('ROWNUM', r'\bROWNUM\b', 'A'),
    ('AND LIMIT (syntax error)', r'\bAND\s+LIMIT\b', 'A'),
    ('WHERE LIMIT (syntax error)', r'\bWHERE\s+LIMIT\b', 'A'),
]

# Oracle names that exist in PostgreSQL with compatible behaviour — never flagged.
PG_COMPATIBLE_NAMES = frozenset({
    'INITCAP', 'TRANSLATE', 'TO_CHAR', 'TO_DATE', 'TO_NUMBER', 'TO_TIMESTAMP',
    'SUBSTR', 'INSTR', 'LPAD', 'RPAD', 'TRUNC', 'SOUNDEX', 'BITAND',
    'NULLIF', 'WIDTH_BUCKET', 'REGEXP_REPLACE', 'REGEXP_LIKE',
    'FOR UPDATE OF', 'USER',
    'NUMBER', 'VARCHAR2', 'NVARCHAR2',
    'CLOB', 'BLOB', 'NCLOB',
    'XMLELEMENT', 'XMLFOREST', 'XMLAGG', 'XMLTABLE',
})

# Oracle names that after conversion become PG custom functions (e.g. sysdate()).
PG_CUSTOM_FUNC_NAMES = frozenset({'SYSDATE', 'SYSTIMESTAMP'})

# Hints shown alongside each residual issue.
CONVERSION_HINTS = {
    'NVL': 'COALESCE(a, b)',
    'NVL2': 'CASE WHEN a IS NOT NULL THEN b ELSE c END',
    'DECODE': 'CASE expr WHEN v1 THEN r1 ... ELSE default END',
    'ADD_MONTHS': "d + INTERVAL 'n months'",
    'MONTHS_BETWEEN': 'EXTRACT(EPOCH FROM age(d1, d2)) / 2592000',
    'SYS_GUID()': 'gen_random_uuid()',
    'SYS_CONTEXT': 'current_user / current_schema / current_database()',
    'ORA_HASH': 'hashtext(expr::TEXT)',
    'LNNVL': 'NOT (expr) IS NOT FALSE',
    'EMPTY_CLOB()': "''",
    'EMPTY_BLOB()': "''",
    'ROWNUM': 'LIMIT n or ROW_NUMBER() OVER ()',
    'AND LIMIT (syntax error)': 'Remove AND before LIMIT',
    'WHERE LIMIT (syntax error)': 'Remove WHERE before LIMIT',
    'ROWID': 'ctid (not recommended)',
    'FROM DUAL': 'Remove FROM DUAL (PostgreSQL allows SELECT without FROM)',
    'INSERT ALL': 'Split into separate INSERT INTO statements',
    'CONNECT BY': 'WITH RECURSIVE cte AS (...)',
    'START WITH': 'Anchor member of WITH RECURSIVE',
    '(+) join': 'LEFT JOIN ... ON ...',
    'MINUS': 'Use EXCEPT',
    '.NEXTVAL': "nextval('sequence_name')",
    '.CURRVAL': "currval('sequence_name')",
    'MERGE INTO': 'INSERT INTO t (...) ON CONFLICT (key) DO UPDATE SET col = EXCLUDED.col',
    'PIVOT': "SUM(x) FILTER (WHERE col = 'A')",
    'UNPIVOT': 'VALUES/LATERAL + UNION ALL or unnest()',
    'BULK COLLECT': 'Use SELECT INTO array or array_agg() in PostgreSQL',
    'SYS_CONNECT_BY_PATH': 'Use string concatenation in recursive CTE',
    'CONNECT_BY_ROOT': 'Carry root column through recursive CTE',
    'LEVEL (hierarchical)': '1 in anchor, cte.level+1 in recursive member',
}
