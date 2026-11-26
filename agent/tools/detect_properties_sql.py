"""`detect_properties_sql` MCP tool.

Deterministic parser for Seasar2 / S2Dao .properties files. Locates
key=value pairs whose value contains a SQL keyword, honoring backslash
line-continuation.
"""

import re

from logging_setup import correlation_id, get_logger


_logger = get_logger('tools.detect_properties_sql')

_SQL_KEYWORD_RE = re.compile(r'\b(SELECT|INSERT|UPDATE|DELETE|MERGE)\b', re.IGNORECASE)


def detect_properties_sql(file_path: str) -> dict:
    """Locate SQL fragments inside a .properties file.

    Args:
        file_path: Absolute path to the .properties file.

    Returns:
        dict with ``hits`` = list of {start_line, end_line, key, sql_text},
        plus ``file`` and ``count``.
    """
    with correlation_id() as cid:
        _logger.info('detect_properties_sql.start', extra={'file': file_path})
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()
        except OSError as e:
            _logger.warning('detect_properties_sql.read_error',
                            extra={'file': file_path, 'err': str(e)})
            return {'file': file_path, 'hits': [], 'count': 0}

        hits = []
        i = 0
        while i < len(lines):
            stripped = lines[i].strip()
            if not stripped or stripped.startswith('#'):
                i += 1
                continue
            if '=' not in stripped:
                i += 1
                continue

            start_line = i + 1
            j = i
            full_value = ''
            while j < len(lines):
                line_text = lines[j].rstrip('\n')
                full_value += line_text
                if not line_text.rstrip().endswith('\\'):
                    break
                j += 1
            end_line = j + 1
            eq_pos = full_value.index('=')
            key = full_value[:eq_pos].strip()
            value = full_value[eq_pos + 1:]

            if _SQL_KEYWORD_RE.search(value):
                # Reconstruct the SQL body without the `key =` prefix and
                # with \n\ line continuations expanded. This is what
                # downstream reconstruction / classification / comparator
                # expects as "the SQL".
                sql_body = value.replace('\\n\\', ' ').replace('\\n', ' ')
                sql_body = re.sub(r'\s+', ' ', sql_body).strip()
                hits.append({
                    'start_line': start_line,
                    'end_line': end_line,
                    'key': key,
                    'sql_text': sql_body,
                })
            i = j + 1

        _logger.info('detect_properties_sql.done',
                     extra={'file': file_path, 'count': len(hits), 'correlation_id': cid})
        return {'file': file_path, 'hits': hits, 'count': len(hits)}
