"""Normalize language-specific placeholders so SQL fragments are parseable.

Every bind or host-interpolation marker is collapsed into a single
PostgreSQL positional placeholder stream (``$1``, ``$2``, …), numbered
left-to-right. This keeps one canonical dialect across assess, convert,
and downstream validators (pglast, ``validate_bind_integrity``).

Handles (outside of single-quoted string literals):

- JDBC ``?``
- JDBC named ``:name``
- MyBatis value ``#{name}``
- MyBatis identifier ``${name}``
- Angle-bracket template ``<name>`` (assess-reconstructed fragments)
- PHP ``$var`` (skips already-numbered ``$1``/``$2``)
- Python format ``{name}``
- printf ``%s`` / ``%d`` / ...
"""

import re


_IDENT_ANGLE = re.compile(r'<[^<>\s=][^<>]*>')
_IDENT_MYBATIS = re.compile(r'\$\{([^}]+)\}')
_IDENT_PHP = re.compile(r'\$(?![0-9])[A-Za-z_][A-Za-z0-9_]*')
_IDENT_PYFMT = re.compile(r'\{([A-Za-z_][A-Za-z0-9_]*)\}')
_IDENT_PRINTF = re.compile(r'%[a-zA-Z]')

# Value placeholders — merged into a single pass so numbering is stable
_VALUE = re.compile(r'#\{[^}]+\}|(?<!:):[A-Za-z_][A-Za-z0-9_]*|\?')


def normalize_placeholders(sql: str) -> str:
    """Replace every placeholder / interpolation marker with ``$1..$n``
    numbered left-to-right."""
    counter = [0]

    def _bump(_match=None) -> str:
        counter[0] += 1
        return f'${counter[0]}'

    # Single left-to-right pass over non-string segments: numbering is
    # stable across all placeholder dialects.
    combined = re.compile(
        r'#\{[^}]+\}'            # MyBatis value
        r'|(?<!:):[A-Za-z_][A-Za-z0-9_]*'   # :name (not ::cast)
        r'|\?'                    # JDBC positional
        r'|\$\{[^}]+\}'           # MyBatis identifier
        r'|<[^<>\s=][^<>]*>'      # <variableName>
        r'|\$(?![0-9])[A-Za-z_][A-Za-z0-9_]*'  # PHP $var (skip $1, $2, ...)
        r'|\{[A-Za-z_][A-Za-z0-9_]*\}'     # Python {var}
        r'|%[a-zA-Z]'             # printf
    )

    return _outside_strings(sql, lambda seg: combined.sub(_bump, seg))


# ---- String-aware walker --------------------------------------------------

_DOLLAR_TAG_RE = re.compile(r'\$[A-Za-z_][A-Za-z0-9_]*\$|\$\$')


def _outside_strings(s: str, apply) -> str:
    out, i, n = [], 0, len(s)
    while i < n:
        c = s[i]
        if c == "'":
            out.append(c)
            i += 1
            while i < n:
                out.append(s[i])
                if s[i] == "'":
                    if i + 1 < n and s[i + 1] == "'":
                        out.append("'")
                        i += 2
                        continue
                    i += 1
                    break
                i += 1
            continue
        # PL/pgSQL dollar-quoted body ($$ ... $$ or $tag$ ... $tag$).
        # Anything inside is passed through verbatim so identifiers
        # like $BODY$ are not rewritten to $1. If the closing tag is
        # missing (malformed input), pass the remainder through too
        # so we never re-scan the same byte (infinite-loop guard).
        if c == '$':
            m = _DOLLAR_TAG_RE.match(s, i)
            if m:
                tag = m.group(0)
                end = s.find(tag, m.end())
                if end >= 0:
                    out.append(s[i:end + len(tag)])
                    i = end + len(tag)
                else:
                    out.append(s[i:])
                    i = n
                continue
        # Accumulate non-string, non-dollar-tag segment
        j = i
        while j < n and s[j] != "'":
            if s[j] == '$' and _DOLLAR_TAG_RE.match(s, j):
                break
            j += 1
        out.append(apply(s[i:j]))
        i = j
    return ''.join(out)
