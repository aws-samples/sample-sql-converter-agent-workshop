"""PostgreSQL syntax validation using pglast.

Parses a SQL string and returns a list of issue dicts describing any syntax
errors. Fragments that clearly are not complete statements (no leading
SELECT/INSERT/...) are skipped — their Oracle residuals are still caught by
the regex detector.

Two layers of PG syntax validation run:

1. ``pglast.parse_sql`` — the core PG SQL parser. Catches surface-level
   SQL syntax errors on every statement, including the wrapper of a
   ``CREATE FUNCTION ... LANGUAGE plpgsql AS $BODY$...$BODY$`` statement.
   However, the dollar-quoted body is treated as an opaque string, so
   anything inside it (typos, Oracle syntax residue) slips through.

2. ``pglast.parse_plpgsql`` — the PL/pgSQL body parser. Only fires when
   the input contains a PL/pgSQL function definition. Catches typos
   inside the body (e.g. ``DECARE`` for ``DECLARE``) and block-
   structural errors the SQL parser cannot see.

Oracle-specific residuals inside a PL/pgSQL body (``NVL``, ``DECODE``,
``ROWNUM``, ``SYSDATE``, etc.) are NOT caught by ``parse_plpgsql`` —
PL/pgSQL accepts any identifier as a function name. They remain the
responsibility of the regex-based residual detector.
"""

import re

try:
    from pglast import parse_plpgsql, parse_sql
    HAS_PGLAST = True
except ImportError:
    parse_sql = None  # type: ignore
    parse_plpgsql = None  # type: ignore
    HAS_PGLAST = False


_FULL_STMT_KEYWORDS = (
    'SELECT', 'INSERT', 'UPDATE', 'DELETE', 'WITH', 'MERGE',
    'CREATE', 'DROP', 'ALTER', 'TRUNCATE',
)
_FIRST_WORD_RE = re.compile(r'\s*(\w+)')

# Matches `CREATE [OR REPLACE] {FUNCTION|PROCEDURE} ... LANGUAGE plpgsql`
# (case-insensitive, LANGUAGE clause may appear before or after the body).
_PLPGSQL_FUNCTION_RE = re.compile(
    r'\bCREATE\s+(?:OR\s+REPLACE\s+)?(?:FUNCTION|PROCEDURE)\b'
    r'.*?\bLANGUAGE\s+\'?plpgsql\'?\b',
    re.IGNORECASE | re.DOTALL,
)


def check_pg_syntax(sql_for_parse: str, original_sql: str) -> list[dict]:
    """Parse ``sql_for_parse`` with pglast. Return issues (empty on success).

    ``original_sql`` is used to decide whether the input is a full
    statement (so that fragments don't trigger noisy syntax errors) and
    to fire the PL/pgSQL body check when the original contained a
    function definition.
    """
    if not HAS_PGLAST:
        return []

    try:
        parse_sql(sql_for_parse)
    except Exception as e:
        err = str(e)
        if 'syntax error' not in err.lower():
            return [_warn(err)]
        if not _is_full_statement(original_sql):
            return []
        if _is_alias_false_positive(sql_for_parse, err):
            return []
        return [_warn(err.split(',')[0])]

    # Outer SQL was parseable. If the statement is a PL/pgSQL function /
    # procedure definition, run the body-level parser too — it catches
    # typos and block-structural errors inside the dollar-quoted body
    # that parse_sql treats as opaque.
    body_issues = _check_plpgsql_body(original_sql)
    return body_issues


def _check_plpgsql_body(sql: str) -> list[dict]:
    """Run pglast.parse_plpgsql on a PL/pgSQL function definition.

    Returns an issues list. Only fires when the SQL text looks like a
    CREATE FUNCTION / PROCEDURE statement with LANGUAGE plpgsql; other
    statements return an empty list without invoking the parser.

    Errors from parse_plpgsql are surfaced as warnings with a hint
    pointing the reviewer / retrying LLM at the body. Oracle-specific
    residuals inside the body (NVL, DECODE, ROWNUM, ...) are NOT
    caught here — PL/pgSQL accepts any identifier as a function name
    — and remain the job of the regex residual detector.
    """
    if not HAS_PGLAST:
        return []
    if not _PLPGSQL_FUNCTION_RE.search(sql):
        return []
    try:
        parse_plpgsql(sql)
        return []
    except Exception as e:
        msg = str(e).split('\n', 1)[0].strip()
        return [{
            'issue': f'PL/pgSQL body syntax error: {msg}',
            'hint': (
                'Check the PL/pgSQL body for typos or non-PG syntax '
                '(e.g. DECARE for DECLARE, missing semicolons, '
                'Oracle-only keywords). The outer CREATE FUNCTION '
                'statement parsed, but the body failed its own '
                'PL/pgSQL parse.'
            ),
            'severity': 'warning',
        }]


def _is_full_statement(sql: str) -> bool:
    m = _FIRST_WORD_RE.match(sql.strip())
    return bool(m and m.group(1).upper() in _FULL_STMT_KEYWORDS)


def _is_alias_false_positive(sql_for_parse: str, err: str) -> bool:
    """Heuristic: dynamic aliases after ``AS`` can trip pglast.

    Strip them and retry. If the stripped version parses, treat the original
    error as a false positive.
    """
    m = re.search(r'at index (\d+)', err)
    if not m:
        return False
    pos = int(m.group(1))
    before = sql_for_parse[max(0, pos - 20):pos]
    if not re.search(r'\bAS\b\s*\S*$', before, re.IGNORECASE):
        return False
    stripped = re.sub(
        r'\bAS\s+(?:[A-Za-z_]\w*)?(?:"[^"]*"\w*)*',
        '',
        sql_for_parse,
        flags=re.IGNORECASE,
    )
    try:
        parse_sql(stripped)
        return True
    except Exception:
        return False


def _warn(msg: str) -> dict:
    return {
        'issue': f'PostgreSQL syntax error: {msg}',
        'hint': 'Fix SQL to be valid PostgreSQL',
        'severity': 'warning',
    }
