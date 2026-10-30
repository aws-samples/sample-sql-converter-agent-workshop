"""Pro*C construct catalogue: pre-classified patterns for Pro*C -> ECPG.

実験的機能（Pro*C対応）。Skill ``domain-proc-to-ecpg`` と対で使う。

Mirrors ``oracle_hints.py`` but for the *precompiler dimension* of a Pro*C
(.pc) source file: EXEC SQL directives, SQLCA/SQLDA runtime idioms, and
precompiler options.

Classification semantics (same A/B/C as the SQL dialect table):
- A = mechanical Pro*C -> ECPG rewrite (both precompilers support it)
- B = supported by ECPG but semantics/API differ — review required
- C = no ECPG equivalent — manual rearchitecture
"""

import re


CONSTRUCT_BASE_CLASS = {
    'dml': 'None',
    'cursor_declare': 'None',
    'cursor_op': 'A',
    'declare_section': 'A',
    'include': 'A',
    'whenever': 'A',
    'connection': 'B',
    'transaction': 'A',
    'dynamic_sql': 'B',
    'plsql_block': 'C',
    'oracle_option': 'B',
    'type_equivalence': 'B',
    'context': 'C',
    'host_code': None,
    'other': 'B',
}


PROC_STATEMENT_FEATURES = [
    ('EXEC SQL FOR :n (host-array bulk op)',
     r'^\s*EXEC\s+SQL\s+FOR\s+', 'B'),
    ('AT clause (named connection)',
     r'^\s*EXEC\s+SQL\s+(?:FOR\s+\S+\s+)?AT\s+', 'B'),
    ('CONNECT ... IDENTIFIED BY',
     r'\bIDENTIFIED\s+BY\b', 'B'),
    ('COMMIT/ROLLBACK ... RELEASE',
     r'\b(?:COMMIT|ROLLBACK)\b[^;]*\bRELEASE\b', 'B'),
    ('ANSI dynamic SQL descriptor (ALLOCATE/GET/SET DESCRIPTOR)',
     r'\b(?:ALLOCATE|DEALLOCATE|GET|SET)\s+DESCRIPTOR\b', 'B'),
    ('EXEC ORACLE OPTION (precompiler option)',
     r'^\s*EXEC\s+ORACLE\b', 'B'),
    ('Datatype equivalencing (EXEC SQL TYPE/VAR)',
     r'^\s*EXEC\s+SQL\s+(?:TYPE|VAR)\b', 'B'),
    ('INCLUDE SQLDA (Oracle SQLDA)',
     r'\bINCLUDE\s+SQLDA\b', 'C'),
    ('DESCRIBE (Method-4 dynamic SQL)',
     r'^\s*EXEC\s+SQL\s+(?:FOR\s+\S+\s+)?(?:AT\s+\S+\s+)?DESCRIBE\b', 'C'),
    ('USING DESCRIPTOR (Oracle SQLDA binding)',
     r'\bUSING\s+DESCRIPTOR\b', 'C'),
    ('INTO DESCRIPTOR (Oracle SQLDA binding)',
     r'\bINTO\s+DESCRIPTOR\b', 'C'),
    ('ARRAYLEN directive',
     r'^\s*EXEC\s+SQL\s+ARRAYLEN\b', 'C'),
    ('Multithreading (ENABLE THREADS / CONTEXT)',
     r'\b(?:ENABLE\s+THREADS|CONTEXT\s+(?:ALLOCATE|USE|FREE))\b', 'C'),
    ('Indicator variable',
     r':[A-Za-z_]\w*\s*(?::[A-Za-z_]|INDICATOR\s+:)', 'A'),
]


PROC_HOST_FEATURES = [
    ('sqlca.sqlcode compared to Oracle status code',
     r'\bsqlca\.sqlcode\b\s*(?:[=!<>]=|[<>])\s*[+-]?\d+', 'B'),
    ('sqlca.sqlerrd access (rows-processed / internals)',
     r'\bsqlca\.sqlerrd\b', 'B'),
    ('sqlca.sqlerrm message struct',
     r'\bsqlca\.sqlerrm\b', 'B'),
    ('sqlca.sqlwarn flags',
     r'\bsqlca\.sqlwarn\b', 'B'),
    ('sqlglm()/sqlgls() error-message API',
     r'\bsqlgl[ms]\s*\(', 'C'),
    ('Oracle SQLDA struct / API (sqlald/sqlclu/sqlnul/sqlprc)',
     r'\bSQLDA\b|\bsql(?:ald|clu|nul|prc)\s*\(', 'C'),
    ('OCI interoperability (sqllda/sqlld2)',
     r'\bsqlld[a2]\s*\(', 'C'),
]


DECLARE_SECTION_FEATURES = [
    ('VARCHAR pseudo-type host variable',
     r'\bVARCHAR\s+\w+\s*\[', 'A'),
]


_FLAGS = re.IGNORECASE | re.MULTILINE

COMPILED_STATEMENT_FEATURES = [
    (name, re.compile(pat, _FLAGS), cls)
    for name, pat, cls in PROC_STATEMENT_FEATURES
]
COMPILED_HOST_FEATURES = [
    (name, re.compile(pat, _FLAGS), cls)
    for name, pat, cls in PROC_HOST_FEATURES
]
COMPILED_DECLARE_FEATURES = [
    (name, re.compile(pat, _FLAGS), cls)
    for name, pat, cls in DECLARE_SECTION_FEATURES
]
