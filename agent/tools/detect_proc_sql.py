"""`detect_proc_sql` MCP tool.

Deterministic detector for Oracle Pro*C (.pc) source files. Locates every
``EXEC SQL`` / ``EXEC ORACLE`` statement, classifies its construct type
(dml / cursor / whenever / dynamic SQL / PL/SQL block / ...), extracts the
embedded SQL where present, and pre-detects Pro*C-specific constructs
(SQLCA idioms, SQLDA Method-4, host arrays, precompiler options) using the
pre-classified table in ``oracle_pg_mcp_server.proc_constructs``.

Unlike host-language source scanning (opengrep taint), EXEC SQL is
self-delimiting — ``EXEC SQL ... ;`` (or ``END-EXEC;`` for embedded PL/SQL
blocks) — so no dataflow analysis is needed. The detector is careful about:

- C comments and string literals that contain fake ``EXEC SQL`` text,
- ``;`` inside SQL string literals / quoted identifiers / SQL comments,
- multi-line statements,
- dynamic SQL text carried in C string literals (Method 1-4), which is
  reported as ``host_string_sql`` hits so it is not silently dropped.

Hit shape is compatible with the other declarative detectors
(start_line / end_line / sql_text) plus ``construct_type``, ``has_sql``
and ``proc_features``.
"""

import bisect
import re

from logging_setup import correlation_id, get_logger
from proc_constructs import (
    COMPILED_DECLARE_FEATURES,
    COMPILED_HOST_FEATURES,
    COMPILED_STATEMENT_FEATURES,
    CONSTRUCT_BASE_CLASS,
)


_logger = get_logger('tools.detect_proc_sql')

_EXEC_RE = re.compile(r'\bEXEC\s+(SQL|ORACLE)\b', re.IGNORECASE)
_END_EXEC_RE = re.compile(r'\bEND-EXEC\b', re.IGNORECASE)
_SQL_KEYWORD_RE = re.compile(
    r'\b(SELECT|INSERT|UPDATE|DELETE|MERGE)\s', re.IGNORECASE)

# Statement-head keyword -> construct_type. Checked in order after the
# EXEC SQL [FOR ...] [AT ...] prefix has been stripped.
_HEAD_RULES = [
    (re.compile(r'^BEGIN\s+DECLARE\s+SECTION', re.IGNORECASE), 'declare_section'),
    (re.compile(r'^END\s+DECLARE\s+SECTION', re.IGNORECASE), 'declare_section'),
    (re.compile(r'^INCLUDE\b', re.IGNORECASE), 'include'),
    (re.compile(r'^WHENEVER\b', re.IGNORECASE), 'whenever'),
    (re.compile(r'^(CONNECT|DISCONNECT)\b', re.IGNORECASE), 'connection'),
    (re.compile(r'^(COMMIT|ROLLBACK|SAVEPOINT|SET\s+TRANSACTION)\b',
                re.IGNORECASE), 'transaction'),
    (re.compile(r'^DECLARE\s+\S+\s+CURSOR\b', re.IGNORECASE), 'cursor_declare'),
    (re.compile(r'^DECLARE\b', re.IGNORECASE), 'other'),  # DATABASE/STATEMENT decl
    (re.compile(r'^(OPEN|FETCH|CLOSE)\b', re.IGNORECASE), 'cursor_op'),
    (re.compile(r'^(PREPARE|EXECUTE\s+IMMEDIATE|DESCRIBE'
                r'|ALLOCATE|DEALLOCATE|GET\s+DESCRIPTOR|SET\s+DESCRIPTOR)\b',
                re.IGNORECASE), 'dynamic_sql'),
    (re.compile(r'^(TYPE|VAR)\b', re.IGNORECASE), 'type_equivalence'),
    (re.compile(r'^(CONTEXT|ENABLE\s+THREADS)\b', re.IGNORECASE), 'context'),
    (re.compile(r'^(SELECT|INSERT|UPDATE|DELETE|MERGE|WITH|LOCK|CALL)\b',
                re.IGNORECASE), 'dml'),
]

_PREFIX_RE = re.compile(
    r'^\s*EXEC\s+SQL\s+(?:(?:FOR\s+:?\w+|AT\s+:?\w+)\s+){0,2}',
    re.IGNORECASE,
)
_PLSQL_EXECUTE_RE = re.compile(
    r'^EXECUTE\s+(BEGIN|DECLARE)\b', re.IGNORECASE)


def _mask_host_code(text: str) -> tuple[str, list[tuple[int, int]]]:
    """Blank C comments and string/char literals with spaces.

    Preserves offsets and newlines so line numbers stay valid. Returns
    (masked_text, string_literal_spans) — the spans of double-quoted C
    string literals (content only) for the dynamic-SQL string scan.
    """
    out = list(text)
    strings: list[tuple[int, int]] = []
    n = len(text)
    i = 0
    state = 'normal'
    start = 0
    while i < n:
        c = text[i]
        if state == 'normal':
            if c == '/' and i + 1 < n and text[i + 1] == '*':
                out[i] = out[i + 1] = ' '
                i += 2
                state = 'block'
                continue
            if c == '/' and i + 1 < n and text[i + 1] == '/':
                out[i] = out[i + 1] = ' '
                i += 2
                state = 'line'
                continue
            if c == '"':
                out[i] = ' '
                start = i + 1
                state = 'dq'
            elif c == "'":
                out[i] = ' '
                state = 'sq'
            i += 1
        elif state == 'block':
            if c == '*' and i + 1 < n and text[i + 1] == '/':
                out[i] = out[i + 1] = ' '
                i += 2
                state = 'normal'
                continue
            if c != '\n':
                out[i] = ' '
            i += 1
        elif state == 'line':
            if c == '\n':
                state = 'normal'
            else:
                out[i] = ' '
            i += 1
        elif state in ('dq', 'sq'):
            quote = '"' if state == 'dq' else "'"
            if c == '\\' and i + 1 < n:
                out[i] = ' '
                if text[i + 1] != '\n':
                    out[i + 1] = ' '
                i += 2
                continue
            if c == '\n':
                # C string/char literals cannot span a raw newline —
                # treat as terminated so an unbalanced quote (e.g. an
                # apostrophe in a SQL comment) cannot poison the rest
                # of the file.
                if state == 'dq':
                    strings.append((start, i))
                state = 'normal'
                i += 1
                continue
            if c == quote:
                if state == 'dq':
                    strings.append((start, i))
                out[i] = ' '
                state = 'normal'
            else:
                out[i] = ' '
            i += 1
    return ''.join(out), strings


def _find_terminator(text: str, start: int) -> int:
    """Return offset just past the ``;`` ending the EXEC statement.

    SQL-aware: skips ``'...'`` strings (with ``''`` escapes), ``"..."``
    quoted identifiers, ``--`` line comments and ``/* */`` block comments.
    Returns -1 if no terminator is found.
    """
    n = len(text)
    i = start
    state = 'normal'
    while i < n:
        c = text[i]
        if state == 'normal':
            if c == ';':
                return i + 1
            if c == "'":
                state = 'sq'
            elif c == '"':
                state = 'dq'
            elif c == '-' and i + 1 < n and text[i + 1] == '-':
                state = 'line'
                i += 1
            elif c == '/' and i + 1 < n and text[i + 1] == '*':
                state = 'block'
                i += 1
        elif state == 'sq':
            if c == "'":
                if i + 1 < n and text[i + 1] == "'":
                    i += 1
                else:
                    state = 'normal'
        elif state == 'dq':
            if c == '"':
                state = 'normal'
        elif state == 'line':
            if c == '\n':
                state = 'normal'
        elif state == 'block':
            if c == '*' and i + 1 < n and text[i + 1] == '/':
                state = 'normal'
                i += 1
        i += 1
    return -1


def _line_index(text: str) -> list[int]:
    """Offsets of every line start, for offset -> 1-based line mapping."""
    idx = [0]
    for m in re.finditer(r'\n', text):
        idx.append(m.end())
    return idx


def _line_of(offsets: list[int], pos: int) -> int:
    return bisect.bisect_right(offsets, pos)


def _strip_prefix(stmt: str) -> str:
    """Remove ``EXEC SQL [FOR x] [AT x]`` and return the statement body."""
    m = _PREFIX_RE.match(stmt)
    return stmt[m.end():].lstrip() if m else stmt


def _classify_head(body: str) -> str:
    if _PLSQL_EXECUTE_RE.match(body):
        return 'plsql_block'
    if re.match(r'^EXECUTE\b', body, re.IGNORECASE):
        return 'dynamic_sql'
    for pat, ctype in _HEAD_RULES:
        if pat.match(body):
            return ctype
    return 'other'


def _extract_sql(construct_type: str, body: str) -> tuple[str, bool]:
    """Return (sql_text, has_sql) for one statement body."""
    if construct_type == 'dml':
        return body.rstrip(';').strip(), True
    if construct_type == 'cursor_declare':
        m = re.match(r'^DECLARE\s+\S+\s+CURSOR\s+(?:WITH\s+HOLD\s+)?FOR\s+',
                     body, re.IGNORECASE)
        if m:
            rest = body[m.end():].rstrip(';').strip()
            # `CURSOR FOR stmt_name` (prepared) carries no inline SQL.
            if re.match(r'^(SELECT|WITH)\b', rest, re.IGNORECASE):
                return rest, True
        return body.rstrip(';').strip(), False
    if construct_type == 'plsql_block':
        m = re.match(r'^EXECUTE\s+', body, re.IGNORECASE)
        block = body[m.end():] if m else body
        block = re.sub(r'\bEND-EXEC\s*;?\s*$', '', block,
                       flags=re.IGNORECASE).strip()
        block = block.rstrip(';').strip() + ';'
        return block, True
    return body.rstrip(';').strip(), False


def _statement_features(stmt_text: str) -> list[dict]:
    feats = []
    for name, pat, cls in COMPILED_STATEMENT_FEATURES:
        if pat.search(stmt_text):
            feats.append({'name': name, 'classification': cls})
    return feats


def detect_proc_sql(file_path: str) -> dict:
    """Locate EXEC SQL statements and Pro*C constructs in a .pc file.

    Args:
        file_path: Absolute path to the Pro*C source file.

    Returns:
        dict with ``hits`` (list), ``file``, ``count``. Each hit:
        ``start_line`` / ``end_line`` (1-based, inclusive),
        ``sql_text`` (embedded SQL, or the raw directive text),
        ``construct_type`` (dml / cursor_declare / cursor_op / whenever /
        include / declare_section / connection / transaction / dynamic_sql /
        plsql_block / oracle_option / type_equivalence / context /
        host_code / host_string_sql / other),
        ``has_sql`` (bool — True when sql_text is analysable SQL),
        ``proc_features`` (list of {name, classification}),
        ``base_classification`` (from CONSTRUCT_BASE_CLASS, may be 'None').
    """
    with correlation_id() as cid:
        _logger.info('detect_proc_sql.start', extra={'file': file_path})
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                text = f.read()
        except OSError as e:
            _logger.warning('detect_proc_sql.read_error',
                            extra={'file': file_path, 'err': str(e)})
            return {'file': file_path, 'hits': [], 'count': 0}

        masked, string_spans = _mask_host_code(text)
        offsets = _line_index(text)
        hits: list[dict] = []
        stmt_spans: list[tuple[int, int]] = []

        # --- Pass 1: EXEC SQL / EXEC ORACLE statements ---
        pos = 0
        declare_bodies: list[str] = []
        pending_declare_start: int | None = None
        while True:
            m = _EXEC_RE.search(masked, pos)
            if not m:
                break
            start = m.start()
            if m.group(1).upper() == 'ORACLE':
                end = _find_terminator(text, start)
                if end == -1:
                    end = text.find('\n', start)
                    end = len(text) if end == -1 else end
                stmt_text = text[start:end]
                hits.append(_make_hit(offsets, start, end, stmt_text,
                                      'oracle_option', stmt_text.strip(),
                                      False))
                stmt_spans.append((start, end))
                pos = end
                continue

            # Peek the head to decide the terminator style.
            head_probe = _strip_prefix(text[start:start + 200])
            is_plsql = bool(_PLSQL_EXECUTE_RE.match(head_probe))
            if is_plsql:
                em = _END_EXEC_RE.search(text, start)
                if em:
                    end = _find_terminator(text, em.end())
                    if end == -1:
                        end = em.end()
                else:
                    end = _find_terminator(text, start)
                    end = len(text) if end == -1 else end
            else:
                end = _find_terminator(text, start)
                if end == -1:
                    _logger.warning('detect_proc_sql.unterminated',
                                    extra={'file': file_path,
                                           'line': _line_of(offsets, start)})
                    end = text.find('\n', start)
                    end = len(text) if end == -1 else end

            stmt_text = text[start:end]
            body = _strip_prefix(stmt_text)
            construct_type = _classify_head(body)
            sql_text, has_sql = _extract_sql(construct_type, body)

            # Track DECLARE SECTION extent so VARCHAR pseudo-types and
            # host-feature scans see the right regions.
            if construct_type == 'declare_section':
                if re.match(r'^BEGIN', body, re.IGNORECASE):
                    pending_declare_start = end
                elif pending_declare_start is not None:
                    declare_bodies.append(text[pending_declare_start:start])
                    pending_declare_start = None

            hits.append(_make_hit(offsets, start, end, stmt_text,
                                  construct_type, sql_text, has_sql))
            stmt_spans.append((start, end))
            pos = end

        # --- Pass 2: VARCHAR pseudo-type inside declare sections ---
        for body in declare_bodies:
            for name, pat, cls in COMPILED_DECLARE_FEATURES:
                if pat.search(body):
                    # Attach to the nearest declare_section hit.
                    for h in hits:
                        if h['construct_type'] == 'declare_section':
                            feats = h['proc_features']
                            if not any(f['name'] == name for f in feats):
                                feats.append(
                                    {'name': name, 'classification': cls})
                            break

        # --- Pass 3: host-code runtime idioms (outside EXEC SQL) ---
        host_masked = list(masked)
        for s, e in stmt_spans:
            for i in range(s, e):
                if host_masked[i] != '\n':
                    host_masked[i] = ' '
        host_text = ''.join(host_masked)
        for name, pat, cls in COMPILED_HOST_FEATURES:
            matches = list(pat.finditer(host_text))
            if not matches:
                continue
            first = matches[0]
            line = _line_of(offsets, first.start())
            snippet_line = text[offsets[line - 1]:
                                offsets[line] if line < len(offsets)
                                else len(text)].rstrip('\n')
            hits.append({
                'start_line': line,
                'end_line': line,
                'sql_text': snippet_line.strip(),
                'construct_type': 'host_code',
                'has_sql': False,
                'proc_features': [{'name': name, 'classification': cls,
                                   'occurrences': len(matches)}],
                'base_classification': cls,
            })

        # --- Pass 4: dynamic SQL text in C string literals ---
        # (skip literals inside EXEC SQL statements, e.g. WHENEVER ... DO)
        for s, e in string_spans:
            if any(ss <= s < se for ss, se in stmt_spans):
                continue
            content = text[s:e]
            if _SQL_KEYWORD_RE.search(content):
                line = _line_of(offsets, s)
                hits.append({
                    'start_line': line,
                    'end_line': _line_of(offsets, e),
                    'sql_text': content,
                    'construct_type': 'host_string_sql',
                    'has_sql': True,
                    'proc_features': [
                        {'name': 'Dynamic SQL text in C string literal',
                         'classification': 'B'}],
                    'base_classification': 'B',
                })

        hits.sort(key=lambda h: (h['start_line'], h['end_line']))
        _logger.info('detect_proc_sql.done',
                     extra={'file': file_path, 'count': len(hits),
                            'correlation_id': cid})
        return {'file': file_path, 'hits': hits, 'count': len(hits)}


def _make_hit(offsets: list[int], start: int, end: int, stmt_text: str,
              construct_type: str, sql_text: str, has_sql: bool) -> dict:
    feats = _statement_features(stmt_text)
    if construct_type == 'plsql_block':
        # Ensure the feature column is never empty for embedded PL/SQL —
        # report metrics and reviewers key off the feature list.
        name = 'Embedded PL/SQL block (EXEC SQL EXECUTE ... END-EXEC)'
        if not any(f['name'] == name for f in feats):
            feats.append({'name': name, 'classification': 'C'})
    base = CONSTRUCT_BASE_CLASS.get(construct_type, 'B') or 'None'
    return {
        'start_line': _line_of(offsets, start),
        'end_line': _line_of(offsets, max(start, end - 1)),
        'sql_text': sql_text,
        'construct_type': construct_type,
        'has_sql': has_sql,
        'proc_features': feats,
        'base_classification': base,
    }
