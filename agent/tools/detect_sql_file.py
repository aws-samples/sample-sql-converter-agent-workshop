"""`detect_sql_file` MCP tool.

Deterministic statement splitter for ``.sql`` files. Walks character by
character with a small state machine to correctly handle semicolons that
appear inside string literals or comments. Skips DDL (CREATE/ALTER/DROP/...)
and PL/SQL blocks (BEGIN/DECLARE/CREATE PROCEDURE/...); returns individual
DML statements (SELECT/INSERT/UPDATE/DELETE/MERGE) separated by ``;``.
"""

import re

from logging_setup import correlation_id, get_logger


_logger = get_logger('tools.detect_sql_file')

_SQL_KEYWORD_RE = re.compile(r'\b(SELECT|INSERT|UPDATE|DELETE|MERGE)\b', re.IGNORECASE)
_PLSQL_BLOCK_RE = re.compile(
    r'^\s*(BEGIN|DECLARE|CREATE\s+(OR\s+REPLACE\s+)?(PROCEDURE|FUNCTION|PACKAGE|TRIGGER|TYPE))\b',
    re.IGNORECASE,
)
_DDL_RE = re.compile(
    r'^\s*(CREATE|ALTER|DROP|TRUNCATE|SET|GRANT|REVOKE)\b',
    re.IGNORECASE,
)


def _split_statements(content: str) -> list[tuple[int, int, str]]:
    """Split SQL text at true statement terminators (semicolons outside
    strings/comments). Returns list of (start_line, end_line, text).
    Leading whitespace is skipped for start_line.
    """
    state = 'normal'      # normal | sq | dq | line_comment | block_comment
    buf: list[str] = []
    stmts: list[tuple[int, int, str]] = []
    line = 1
    stmt_start_line: int | None = None
    stmt_start_buf_pos = 0

    i = 0
    n = len(content)
    while i < n:
        c = content[i]
        nxt = content[i + 1] if i + 1 < n else ''
        if state == 'normal':
            if c == "'":
                state = 'sq'
            elif c == '"':
                state = 'dq'
            elif c == '-' and nxt == '-':
                state = 'line_comment'
                buf.append(c); buf.append(nxt); i += 2
                continue
            elif c == '/' and nxt == '*':
                state = 'block_comment'
                buf.append(c); buf.append(nxt); i += 2
                continue
            elif c == ';':
                buf.append(c)
                stmt_text = ''.join(buf)
                if stmt_start_line is None:
                    stmt_start_line = line
                stmts.append((stmt_start_line, line, stmt_text.strip()))
                buf = []
                stmt_start_line = None
                i += 1
                continue
            else:
                if stmt_start_line is None and not c.isspace():
                    stmt_start_line = line
        elif state == 'sq':
            if c == "'" and nxt == "'":
                buf.append(c); buf.append(nxt); i += 2; line += (c == '\n') + (nxt == '\n'); continue
            if c == "'":
                state = 'normal'
        elif state == 'dq':
            if c == '"':
                state = 'normal'
        elif state == 'line_comment':
            if c == '\n':
                state = 'normal'
        elif state == 'block_comment':
            if c == '*' and nxt == '/':
                buf.append(c); buf.append(nxt); i += 2; state = 'normal'; continue

        buf.append(c)
        if c == '\n':
            line += 1
        i += 1

    # Trailing buffer without terminator. ``line`` has typically been
    # incremented past the last line of content by the final newline(s);
    # report end_line as the last line that actually held text so the
    # span matches ``readlines()`` semantics used by the CLI.
    tail = ''.join(buf).strip()
    if tail:
        content_lines = ''.join(buf).splitlines()
        end_line = (stmt_start_line or 1) + max(len(content_lines) - 1, 0)
        stmts.append((stmt_start_line or line, end_line, tail))
    return stmts


def detect_sql_file(file_path: str) -> dict:
    """Locate DML statements inside a .sql file.

    Skips DDL and PL/SQL blocks. Correctly handles semicolons inside string
    literals and comments. Each returned hit spans from the first line of
    the statement through its terminating ``;`` (or end of file).

    Args:
        file_path: Absolute path to the .sql file.

    Returns:
        dict with ``hits`` = list of {start_line, end_line, sql_text},
        plus ``file`` and ``count``.
    """
    with correlation_id() as cid:
        _logger.info('detect_sql_file.start', extra={'file': file_path})
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except OSError as e:
            _logger.warning('detect_sql_file.read_error',
                            extra={'file': file_path, 'err': str(e)})
            return {'file': file_path, 'hits': [], 'count': 0}

        if _PLSQL_BLOCK_RE.match(content.lstrip()):
            return {'file': file_path, 'hits': [], 'count': 0}

        hits = []
        for start_line, end_line, text in _split_statements(content):
            stripped = text.lstrip()
            if not stripped:
                continue
            # Filter out DDL / PL/SQL blocks / non-DML
            if _DDL_RE.match(stripped) or _PLSQL_BLOCK_RE.match(stripped):
                continue
            if not _SQL_KEYWORD_RE.search(stripped):
                continue
            hits.append({
                'start_line': start_line,
                'end_line': end_line,
                'sql_text': text,
            })

        _logger.info('detect_sql_file.done',
                     extra={'file': file_path, 'count': len(hits), 'correlation_id': cid})
        return {'file': file_path, 'hits': hits, 'count': len(hits)}
