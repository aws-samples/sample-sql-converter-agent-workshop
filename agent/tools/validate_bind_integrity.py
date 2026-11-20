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


def compare_host_placeholders(source_text: str, converted_text: str) -> list[dict]:
    """Check that a line-range replacement in host source code keeps its
    placeholders (used by write_app_convert_outputs before writing).

    Unlike ``validate_bind_integrity`` (which compares the original SQL with a
    normalized ``$1..$n`` view), both sides here are raw host code in the same
    dialect, so the text is not stripped and the check is stricter on dialect:

    - positional placeholders (``?``, ``%s``, ``$n``) keep the same count;
    - named placeholders (``:name``, ``%(name)s``, ``#{name}``, ``${name}``)
      keep the same set of names in the same style (``${x}`` must not become
      ``#{x}``). The number of times a named placeholder appears may change,
      because named binding does not depend on position.

    One style change is allowed: MyBatis ``${x}`` -> ``#{x}`` with the same
    name (string substitution -> bind parameter, a SQL injection fix). Use
    ``dollar_to_hash_names`` to list such changes so they can be reported.
    """
    issues: list[dict] = []
    moved = set(dollar_to_hash_names(source_text, converted_text))

    def _count(rx):
        return len(rx.findall(source_text or '')), len(rx.findall(converted_text or ''))

    for label, rx in (('?', _POSITIONAL_RE), ('%s', _PY_PERCENT_RE)):
        before, after = _count(rx)
        if before != after:
            issues.append({'issue': f'positional placeholder {label}: {before} -> {after}'})

    src_pg = sorted(_PG_NUMBERED_RE.findall(source_text or ''))
    dst_pg = sorted(_PG_NUMBERED_RE.findall(converted_text or ''))
    if src_pg != dst_pg:
        issues.append({'issue': f'positional placeholder $n: {src_pg} -> {dst_pg}'})

    for label, rx in ((':name', _NAMED_COLON_RE), ('%(name)s', _PY_PYFORMAT_RE),
                      ('#{name}', _MYBATIS_HASH_RE), ('${name}', _MYBATIS_DOLLAR_RE)):
        before = set(rx.findall(source_text or ''))
        after = set(rx.findall(converted_text or ''))
        if label == '#{name}':
            after -= moved
        elif label == '${name}':
            before -= moved
        if before != after:
            removed = sorted(before - after)
            added = sorted(after - before)
            issues.append({'issue': f'named placeholder {label}: removed {removed}, added {added}'})
    return issues


def dollar_to_hash_names(source_text: str, converted_text: str) -> list[str]:
    """Names that were MyBatis ``${name}`` in the source and became
    ``#{name}`` in the converted text."""
    src_d = set(_MYBATIS_DOLLAR_RE.findall(source_text or ''))
    dst_d = set(_MYBATIS_DOLLAR_RE.findall(converted_text or ''))
    src_h = set(_MYBATIS_HASH_RE.findall(source_text or ''))
    dst_h = set(_MYBATIS_HASH_RE.findall(converted_text or ''))
    return sorted((src_d - dst_d) & (dst_h - src_h))
