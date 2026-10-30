"""Validate that a SQL rewrite preserves bind-parameter integrity.

Counts and extracts placeholders of each dialect so the convert pipeline
can detect LLM rewrites that would break host-code bindings (e.g.
replacing hard-coded ``SYSDATE`` with a ``?`` that has no matching
``stmt.setTimestamp`` call).

Supported placeholder flavours:
  - ``?``              — JDBC / ODBC positional
  - ``$1`` … ``$N``    — PostgreSQL / psycopg positional
  - ``%s``             — Python DB-API positional
  - ``:name``          — Oracle / Hibernate named
  - ``%(name)s``       — Python DB-API pyformat named
  - ``#{name}``        — MyBatis positional-by-name
  - ``${name}``        — MyBatis raw interpolation

Literals, string contents, and SQL comments are stripped before counting so
matches like ``'%s'`` in a VARCHAR literal are not miscounted.
"""
from __future__ import annotations

import re


_STRIP_RE = re.compile(
    r"""(
        '(?:''|[^'])*'        # single-quoted literal (SQL escaping '')
        | "(?:""|[^"])*"      # double-quoted identifier
        | --[^\n]*             # line comment
        | /\*.*?\*/           # block comment
    )""",
    re.VERBOSE | re.DOTALL,
)

_POSITIONAL_RE = re.compile(r'\?')
_PG_NUMBERED_RE = re.compile(r'\$(\d+)')
_PY_PERCENT_RE = re.compile(r'%s')
_NAMED_COLON_RE = re.compile(r'(?<!:):(?!:)([A-Za-z_][A-Za-z0-9_]*)')
_PY_PYFORMAT_RE = re.compile(r'%\(([A-Za-z_][A-Za-z0-9_]*)\)s')
_MYBATIS_HASH_RE = re.compile(r'#\{([^}]+)\}')
_MYBATIS_DOLLAR_RE = re.compile(r'\$\{([^}]+)\}')


def _strip(sql: str) -> str:
    return _STRIP_RE.sub('', sql or '')


def extract_bind_placeholders(sql: str) -> dict:
    """Return a summary of placeholders found in ``sql``."""
    stripped = _strip(sql)
    return {
        'positional_qmark':    len(_POSITIONAL_RE.findall(stripped)),
        'positional_pg':       [int(m) for m in _PG_NUMBERED_RE.findall(stripped)],
        'positional_percent':  len(_PY_PERCENT_RE.findall(stripped)),
        'named_colon':         _NAMED_COLON_RE.findall(stripped),
        'named_pyformat':      _PY_PYFORMAT_RE.findall(stripped),
        'mybatis_hash':        _MYBATIS_HASH_RE.findall(stripped),
        'mybatis_dollar':      _MYBATIS_DOLLAR_RE.findall(stripped),
    }


def validate_bind_integrity(source_sql: str, converted_sql: str) -> dict:
    """Compare placeholder integrity between ``source_sql`` and ``converted_sql``.

    Returns a dict::

        {
            'clean': bool,
            'issues': [ { 'issue': '...', 'hint': '...' } ],
            'source':   <extract_bind_placeholders(source)>,
            'converted': <extract_bind_placeholders(converted)>,
        }

    Compares the TOTAL NUMBER of placeholders across all flavours
    (not their dialect), which catches the LLM silently adding or
    dropping a placeholder without false-flagging legitimate
    dialect differences (e.g. ``#{name}`` in the original vs
    ``$1`` in a normalized PostgreSQL view of the same SQL).
    """
    src = extract_bind_placeholders(source_sql)
    dst = extract_bind_placeholders(converted_sql)
    issues: list[dict] = []

    def _total(p: dict) -> int:
        return (p['positional_qmark']
                + len(p['positional_pg'])
                + p['positional_percent']
                + len(p['named_colon'])
                + len(p['named_pyformat'])
                + len(p['mybatis_hash'])
                + len(p['mybatis_dollar']))

    src_total = _total(src)
    dst_total = _total(dst)
    if src_total != dst_total:
        issues.append({
            'issue': f'total bind placeholder count {src_total} -> {dst_total}',
            'hint': 'Preserve the total number of bind placeholders '
                    '(regardless of dialect) so the host-code bindings '
                    'still bind correctly. Do not replace hard-coded '
                    'values (e.g. SYSDATE) with new placeholders.',
        })

    return {
        'clean': not issues,
        'issues': issues,
        'source': src,
        'converted': dst,
    }
