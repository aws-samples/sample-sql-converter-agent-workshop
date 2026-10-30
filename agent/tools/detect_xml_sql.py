"""`detect_xml_sql` MCP tool.

Deterministic line-based XML tag parser to locate SQL fragments inside
MyBatis / Hibernate / iBATIS mapper XML. `start_line` is the FIRST line
inside the tag body that contains a SQL keyword (not the opening tag line).

Used during the file-granularity pipeline when the file extension is .xml
(in place of opengrep-based detection, which is for source code).
"""

import re

from logging_setup import correlation_id, get_logger


_logger = get_logger('tools.detect_xml_sql')

_SQL_KEYWORD_RE = re.compile(r'\b(SELECT|INSERT|UPDATE|DELETE|MERGE)\b', re.IGNORECASE)
_OPEN_TAG_RE = re.compile(
    r'<(select|insert|update|delete|sql-query|named-query|statement|query)\b(?!-)',
    re.IGNORECASE,
)
_CLOSE_TAG_RE = re.compile(
    r'</(select|insert|update|delete|sql-query|named-query|statement|query)>',
    re.IGNORECASE,
)


def detect_xml_sql(file_path: str) -> dict:
    """Locate SQL fragments inside a mapper XML file.

    Algorithm:
    1. Walk lines; on an opening SQL tag, search up to 300 lines ahead for its
       matching closing tag.
    2. Within the tag block, the first line that contains a SQL keyword
       (SELECT/INSERT/UPDATE/DELETE/MERGE) becomes ``start_line`` (1-based).
    3. ``end_line`` is the closing tag line.

    Args:
        file_path: Absolute path to the XML file.

    Returns:
        dict with ``hits`` = list of {start_line, end_line, sql_text,
        variant_hint (str)}, plus ``file`` and ``count``.
    """
    with correlation_id() as cid:
        _logger.info('detect_xml_sql.start', extra={'file': file_path})
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()
        except OSError as e:
            _logger.warning('detect_xml_sql.read_error', extra={'file': file_path, 'err': str(e)})
            return {'file': file_path, 'hits': [], 'count': 0}

        hits = []
        i = 0
        while i < len(lines):
            if not _OPEN_TAG_RE.search(lines[i]):
                i += 1
                continue
            tag_start = i
            tag_end = None
            for j in range(i, min(i + 300, len(lines))):
                if _CLOSE_TAG_RE.search(lines[j]):
                    tag_end = j
                    break
            if tag_end is None:
                i += 1
                continue

            sql_line = None
            has_cdata = False
            for k in range(tag_start, tag_end + 1):
                text = lines[k]
                if '<![CDATA[' in text:
                    has_cdata = True
                if k == tag_start and k == tag_end and _SQL_KEYWORD_RE.search(text):
                    sql_line = k + 1
                    break
                if _OPEN_TAG_RE.search(text) or _CLOSE_TAG_RE.search(text):
                    continue
                if _SQL_KEYWORD_RE.search(text):
                    sql_line = k + 1
                    break
            if sql_line is None:
                i = tag_end + 1
                continue

            end_line = tag_end + 1
            if has_cdata:
                for k in range(tag_end, sql_line - 1, -1):
                    t = lines[k]
                    stripped = t.replace(']]>', '').strip()
                    is_terminator_only = (
                        ']]>' in t and (
                            not stripped
                            or _CLOSE_TAG_RE.fullmatch(stripped)
                            or stripped.startswith('</')
                        )
                    )
                    if is_terminator_only:
                        end_line = k
                        continue
                    break

            source = ''.join(lines[tag_start:tag_end + 1]).rstrip('\n')

            if_count = source.count('<if ')
            choose_count = source.count('<choose')
            variant_hint = ''
            if if_count or choose_count:
                total = 1
                parts = []
                if if_count:
                    total *= 2 ** if_count
                    parts.append(f'2^{if_count} from <if>')
                if choose_count:
                    when_count = source.count('<when') + min(source.count('<otherwise'), 1)
                    total *= max(when_count, 1)
                    parts.append(f'{when_count} from <choose>')
                variant_hint = f'{total} = ' + ' x '.join(parts)

            hits.append({
                'start_line': sql_line,
                'end_line': end_line,
                'sql_text': source,
                'variant_hint': variant_hint,
            })
            i = tag_end + 1

        _logger.info('detect_xml_sql.done',
                     extra={'file': file_path, 'count': len(hits), 'correlation_id': cid})
        return {'file': file_path, 'hits': hits, 'count': len(hits)}
