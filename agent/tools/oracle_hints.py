"""Pre-detect Oracle-specific features in source code using regex.
Each feature has a pre-assigned classification (A/B/C) to guide LLM."""
import re

# (display_name, regex_pattern, classification)
# Classification: A=auto-convertible, B=review needed, C=manual conversion
ORACLE_FEATURES = [
    # --- A: Auto-convertible ---
    # Functions
    ('NVL', r'\bNVL\s*\(', 'A'),
    ('NVL2', r'\bNVL2\s*\(', 'A'),
    ('DECODE', r'\bDECODE\s*\(', 'A'),
    ('SYSDATE', r'\bSYSDATE\b', 'A'),
    ('SYSTIMESTAMP', r'\bSYSTIMESTAMP\b', 'A'),
    ('SYS_GUID()', r'\bSYS_GUID\s*\(', 'A'),
    ('SYS_CONTEXT', r'\bSYS_CONTEXT\s*\(', 'B'),
    # TO_DATE(TO_CHAR(x, fmt), fmt) is a time-stripping idiom that requires
    # review (legacy classification rule: prompt_classification.md §B).
    # Declared BEFORE single TO_CHAR/TO_DATE so the B match wins via
    # worst-class order (they are detected independently and worst wins).
    ('TO_DATE(TO_CHAR(...))', r'\bTO_DATE\s*\(\s*TO_CHAR\s*\(', 'B'),
    # Oracle-specific NLS date format masks (RR, SYYY, J, W, WW, IW, etc.).
    # Legacy prompt_classification.md: TO_CHAR/TO_DATE with NLS or
    # Oracle-specific format → B.
    ('TO_CHAR/TO_DATE with Oracle NLS format',
     r'\bTO_(?:CHAR|DATE)\s*\([^)]*["\'][^"\']*(\bRR\b|\bSYYY\b|\bJ\b|\bIW\b|\bWW\b|"MONTH"|"DAY")',
     'B'),
    ('TO_CHAR', r'\bTO_CHAR\s*\(', 'A'),
    ('TO_DATE', r'\bTO_DATE\s*\(', 'A'),
    ('TO_NUMBER', r'\bTO_NUMBER\s*\(', 'A'),
    # Oracle data types in CAST expressions
    ('NUMBER', r'\bNUMBER\b(?:\s*\(\s*\d+)', 'A'),
    ('VARCHAR2', r'\bVARCHAR2\s*\(', 'A'),
    ('NVARCHAR2', r'\bNVARCHAR2\s*\(', 'A'),
    ('TRUNC', r'\bTRUNC\s*\(', 'A'),
    ('ROUND', r'\bROUND\s*\(', 'A'),
    ('ADD_MONTHS', r'\bADD_MONTHS\s*\(', 'A'),
    ('MONTHS_BETWEEN', r'\bMONTHS_BETWEEN\s*\(', 'A'),
    ('SUBSTR', r'\bSUBSTR\s*\(', 'A'),
    ('INSTR', r'\bINSTR\s*\(', 'A'),
    ('LPAD', r'\bLPAD\s*\(', 'A'),
    ('RPAD', r'\bRPAD\s*\(', 'A'),
    ('INITCAP', r'\bINITCAP\s*\(', 'A'),
    ('LENGTHB', r'\bLENGTHB\s*\(', 'A'),
    ('ORA_HASH', r'\bORA_HASH\s*\(', 'A'),
    ('LNNVL', r'\bLNNVL\s*\(', 'A'),
    ('EMPTY_CLOB()', r'\bEMPTY_CLOB\s*\(', 'A'),
    ('EMPTY_BLOB()', r'\bEMPTY_BLOB\s*\(', 'A'),
    ('NANVL', r'\bNANVL\s*\(', 'A'),
    # Sequence
    ('.NEXTVAL', r'\.\s*NEXTVAL\b', 'A'),
    ('.CURRVAL', r'\.\s*CURRVAL\b', 'A'),
    # Syntax
    ('FROM DUAL', r'\bFROM\s+DUAL\b', 'A'),
    # ROWNUM is context-dependent (A/B/C) — left to LLM classification
    # Simple top-N (WHERE ROWNUM <= N) = A
    # Pagination (ROWNUM + rn > ?) = B
    # Expression (LPAD(ROWNUM), CEIL(ROWNUM/N)) = C

    # --- A: Auto-convertible (additional) ---
    # Date/Time
    ('NEXT_DAY', r'\bNEXT_DAY\s*\(', 'A'),
    ('LAST_DAY', r'\bLAST_DAY\s*\(', 'A'),
    ('NEW_TIME', r'\bNEW_TIME\s*\(', 'A'),
    ('NUMTODSINTERVAL', r'\bNUMTODSINTERVAL\s*\(', 'A'),
    ('NUMTOYMINTERVAL', r'\bNUMTOYMINTERVAL\s*\(', 'A'),
    ('SESSIONTIMEZONE', r'\bSESSIONTIMEZONE\b', 'A'),
    ('DBTIMEZONE', r'\bDBTIMEZONE\b', 'A'),
    # String
    ('TRANSLATE', r'\bTRANSLATE\s*\(', 'A'),
    ('ASCIISTR', r'\bASCIISTR\s*\(', 'A'),
    ('UNISTR', r'\bUNISTR\s*\(', 'A'),
    ('SOUNDEX', r'\bSOUNDEX\s*\(', 'A'),
    ('DUMP', r'\bDUMP\s*\(', 'A'),
    ('VSIZE', r'\bVSIZE\s*\(', 'A'),
    # Numeric
    ('REMAINDER', r'\bREMAINDER\s*\(', 'A'),
    ('BITAND', r'\bBITAND\s*\(', 'A'),
    ('WIDTH_BUCKET', r'\bWIDTH_BUCKET\s*\(', 'A'),
    # Conversion
    ('TO_TIMESTAMP', r'\bTO_TIMESTAMP\s*\(', 'A'),
    ('TO_CLOB', r'\bTO_CLOB\s*\(', 'A'),
    ('TO_BLOB', r'\bTO_BLOB\s*\(', 'A'),
    ('TO_NCLOB', r'\bTO_NCLOB\s*\(', 'A'),
    ('HEXTORAW', r'\bHEXTORAW\s*\(', 'A'),
    ('RAWTOHEX', r'\bRAWTOHEX\s*\(', 'A'),
    ('CHARTOROWID', r'\bCHARTOROWID\s*\(', 'A'),
    ('ROWIDTOCHAR', r'\bROWIDTOCHAR\s*\(', 'A'),
    # Environment
    ('USER', r'\bUSER\b(?!\s*[_a-zA-Z])', 'A'),
    ('USERENV', r'\bUSERENV\s*\(', 'A'),
    # Misc
    ('STANDARD_HASH', r'\bSTANDARD_HASH\s*\(', 'A'),
    ('JSON_VALUE', r'\bJSON_VALUE\s*\(', 'A'),
    ('JSON_EXISTS', r'\bJSON_EXISTS\s*\(', 'A'),

    # --- B: Review recommended (additional) ---
    ('REGEXP_REPLACE', r'\bREGEXP_REPLACE\s*\(', 'B'),
    ('RATIO_TO_REPORT', r'\bRATIO_TO_REPORT\s*\(', 'B'),
    ('KEEP', r'\bKEEP\s*\(', 'B'),
    ('PERCENTILE_CONT', r'\bPERCENTILE_CONT\s*\(', 'B'),
    ('PERCENTILE_DISC', r'\bPERCENTILE_DISC\s*\(', 'B'),
    ('STATS_MODE', r'\bSTATS_MODE\s*\(', 'B'),
    ('TO_TIMESTAMP_TZ', r'\bTO_TIMESTAMP_TZ\s*\(', 'B'),
    ('FROM_TZ', r'\bFROM_TZ\s*\(', 'B'),
    ('XMLELEMENT', r'\bXMLELEMENT\s*\(', 'B'),
    ('XMLFOREST', r'\bXMLFOREST\s*\(', 'B'),
    ('XMLAGG', r'\bXMLAGG\s*\(', 'B'),
    ('XMLTABLE', r'\bXMLTABLE\s*\(', 'B'),
    ('ROWID', r'\bROWID\b', 'B'),

    # --- C: Manual conversion (additional) ---
    ('CONNECT_BY_ISCYCLE', r'\bCONNECT_BY_ISCYCLE\b', 'C'),
    ('NOCYCLE', r'\bNOCYCLE\b', 'C'),
    ('SDO_', r'\bSDO_\w+', 'C'),
    ('CTX_', r'\bCTX_\w+', 'C'),
    ('OWA_', r'\bOWA_\w+', 'C'),
    ('HTF_', r'\bHTF\.\w+', 'C'),
    ('HTP_', r'\bHTP\.\w+', 'C'),
    ('APEX_', r'\bAPEX_\w+', 'C'),
    ('MULTISET', r'\bMULTISET\b', 'C'),
    ('TREAT', r'\bTREAT\s*\(', 'C'),

    # --- B: Review recommended ---
    ('MINUS', r'\bMINUS\b', 'B'),
    ('MERGE INTO', r'\bMERGE\s+INTO\b', 'B'),
    ('INSERT ALL', r'\bINSERT\s+ALL\b', 'B'),
    ('INSERT FIRST', r'\bINSERT\s+FIRST\b', 'B'),
    ('(+) join', r'\(\+\)', 'B'),
    ('LISTAGG', r'\bLISTAGG\s*\(', 'B'),
    ('WM_CONCAT', r'\bWM_CONCAT\s*\(', 'B'),
    ('MEDIAN', r'\bMEDIAN\s*\(', 'B'),
    ('REGEXP_LIKE', r'\bREGEXP_LIKE\s*\(', 'B'),
    ('REGEXP_SUBSTR', r'\bREGEXP_SUBSTR\s*\(', 'B'),
    ('REGEXP_INSTR', r'\bREGEXP_INSTR\s*\(', 'B'),
    ('REGEXP_COUNT', r'\bREGEXP_COUNT\s*\(', 'B'),
    ('RETURNING INTO', r'\bRETURNING\s+INTO\b', 'B'),
    ('FOR UPDATE WAIT', r'\bFOR\s+UPDATE\s+WAIT\b', 'C'),
    # FOR UPDATE NOWAIT / FOR UPDATE OF / FOR UPDATE SKIP LOCKED are all
    # supported natively by PostgreSQL — not flagged (legacy Standard SQL
    # list in prompt_classification.md).
    # Oracle partition extension syntax: table PARTITION(p1), table SUBPARTITION(sp1)
    ('PARTITION()', r'\bPARTITION\s*\(', 'C'),
    ('SUBPARTITION()', r'\bSUBPARTITION\s*\(', 'C'),
    ('SAMPLE', r'\bSAMPLE\s*\(', 'B'),
    ('XMLTYPE', r'\bXMLTYPE\b', 'B'),
    ('CLOB', r'\bCLOB\b', 'B'),
    ('BLOB', r'\bBLOB\b', 'B'),
    ('NCLOB', r'\bNCLOB\b', 'B'),

    # --- C: Manual conversion ---
    ('PIVOT', r'\bPIVOT\s*\(', 'C'),
    ('UNPIVOT', r'\bUNPIVOT\s*\(', 'C'),
    ('CONNECT BY', r'\bCONNECT\s+BY\b', 'C'),
    ('START WITH', r'\bSTART\s+WITH\b', 'C'),
    ('SYS_CONNECT_BY_PATH', r'\bSYS_CONNECT_BY_PATH\s*\(', 'C'),
    ('CONNECT_BY_ROOT', r'\bCONNECT_BY_ROOT\b', 'C'),
    ('CONNECT_BY_ISLEAF', r'\bCONNECT_BY_ISLEAF\b', 'C'),
    ('LEVEL (hierarchical)', r'\bLEVEL\b(?=.*\bCONNECT\s+BY\b)', 'C'),  # Only with CONNECT BY
    ('PRIOR', r'\bPRIOR\b', 'C'),
    ('ORDER SIBLINGS BY', r'\bORDER\s+SIBLINGS\s+BY\b', 'C'),
    ('BULK COLLECT', r'\bBULK\s+COLLECT\b', 'C'),
    ('COLLECT()', r'(?i)\bCOLLECT\s*\((?!Collectors)', 'C'),
    ('FORALL', r'\bFORALL\b', 'C'),
    ('TABLE()', r'\bTABLE\s*\(', 'C'),
    ('VARRAY', r'\bVARRAY\b', 'C'),
    ('USER_* (data dict)', r'\bUSER_(TABLES|OBJECTS|TAB_COLUMNS|INDEXES|CONSTRAINTS|SEQUENCES|VIEWS|SOURCE|PROCEDURES|TRIGGERS|TYPES|SYNONYMS|TAB_PRIVS|SYS_PRIVS|ROLE_PRIVS|SEGMENTS|EXTENTS|TABLESPACES|RECYCLEBIN|ERRORS|DEPENDENCIES|JOBS|SCHEDULER_JOBS)\b', 'C'),
    ('DBA_* (data dict)', r'\bDBA_(TABLES|OBJECTS|TAB_COLUMNS|INDEXES|CONSTRAINTS|SEQUENCES|VIEWS|SOURCE|PROCEDURES|TRIGGERS|TYPES|SYNONYMS|SEGMENTS|EXTENTS|TABLESPACES|USERS|ROLES|DATA_FILES|FREE_SPACE|JOBS|SCHEDULER_JOBS)\b', 'C'),
    ('ALL_* (data dict)', r'\bALL_(TABLES|OBJECTS|TAB_COLUMNS|INDEXES|CONSTRAINTS|SEQUENCES|VIEWS|SOURCE|PROCEDURES|TRIGGERS|TYPES|SYNONYMS)\b', 'C'),
    ('V$', r'\bV\$\w+', 'C'),
    ('X$', r'\bX\$\w+', 'C'),
    ('DBMS_', r'\bDBMS_\w+', 'C'),
    ('UTL_', r'\bUTL_\w+', 'C'),
]

# Compile patterns once
_COMPILED = [(name, re.compile(pat, re.IGNORECASE), cls) for name, pat, cls in ORACLE_FEATURES]


def detect_oracle_hints(source_code: str) -> str:
    """Return Oracle features found with their classifications.
    Format: 'NVL(A), MINUS(B), CONNECT BY(C)'
    Returns empty string if none found."""
    found = []
    for name, pat, cls in _COMPILED:
        if pat.search(source_code):
            found.append(f'{name}({cls})')
    return ', '.join(found)
