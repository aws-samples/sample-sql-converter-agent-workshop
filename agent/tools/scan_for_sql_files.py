"""Project scanner: walk a source tree, categorize files containing SQL.

Core scan logic plus the ``scan_for_sql_files`` MCP tool wrapper
(jsonl output for large projects).
"""

import hashlib
import json
import os
import re
import tempfile
from pathlib import Path

from logging_setup import correlation_id, get_logger


_logger = get_logger('tools.scan_for_sql_files')

DEFAULT_EXCLUDE_DIRS = frozenset({
    'node_modules', 'target', 'build', 'dist', '__pycache__',
    'migration-output', '.git', '.venv', 'venv',
})

DEFAULT_SOURCE_EXT = frozenset({
    '.java', '.py', '.js', '.ts', '.php', '.c', '.cpp', '.h', '.rb', '.cs', '.vb',
})
DEFAULT_XML_EXT = frozenset({'.xml'})
DEFAULT_SQL_EXT = frozenset({'.sql'})
DEFAULT_PROPS_EXT = frozenset({'.properties'})
DEFAULT_PROC_EXT = frozenset({'.pc'})

_SQL_KEYWORD_RE = re.compile(r'\b(SELECT|INSERT|UPDATE|DELETE|MERGE|WITH)\s', re.IGNORECASE)
_PROC_MARKER_RE = re.compile(r'\bEXEC\s+(SQL|ORACLE)\b', re.IGNORECASE)


def walk_files(root, extensions=None, exclude_dirs=None, exclude_ext=None):
    """Yield paths under `root` whose extension is in `extensions`."""
    exclude_dirs = exclude_dirs or DEFAULT_EXCLUDE_DIRS
    exclude_ext = exclude_ext or frozenset()
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if not d.startswith('.') and d not in exclude_dirs]
        for fname in filenames:
            ext = os.path.splitext(fname)[1].lower()
            if ext in exclude_ext:
                continue
            if extensions is not None and ext not in extensions:
                continue
            yield os.path.join(dirpath, fname)


def classify_file(path, source_ext=None, xml_ext=None, sql_ext=None, props_ext=None):
    """Return category for ``path``:
    'source' | 'xml' | 'sql' | 'properties' | 'proc' | None."""
    source_ext = source_ext or DEFAULT_SOURCE_EXT
    xml_ext = xml_ext or DEFAULT_XML_EXT
    sql_ext = sql_ext or DEFAULT_SQL_EXT
    props_ext = props_ext or DEFAULT_PROPS_EXT
    ext = os.path.splitext(path)[1].lower()
    if ext in DEFAULT_PROC_EXT:
        return 'proc'
    if ext in sql_ext:
        return 'sql'
    if ext in xml_ext:
        return 'xml'
    if ext in props_ext:
        return 'properties'
    if ext in source_ext:
        return 'source'
    return None


def _file_contains_sql(path):
    try:
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            return bool(_SQL_KEYWORD_RE.search(f.read()))
    except OSError:
        return False


def _file_contains_proc(path):
    try:
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            return bool(_PROC_MARKER_RE.search(f.read()))
    except OSError:
        return False


def _scan(project_root, *, source_ext=None, xml_ext=None, sql_ext=None,
          props_ext=None, exclude_dirs=None, exclude_ext=None):
    """Discover files containing SQL, categorized by type.

    Returns a dict with keys ``source``, ``xml``, ``sql``,
    ``properties``, ``proc`` — each mapping to a sorted list of
    absolute paths.
    """
    source_ext = source_ext or DEFAULT_SOURCE_EXT
    xml_ext = xml_ext or DEFAULT_XML_EXT
    sql_ext = sql_ext or DEFAULT_SQL_EXT
    props_ext = props_ext or DEFAULT_PROPS_EXT
    all_ext = source_ext | xml_ext | sql_ext | props_ext | DEFAULT_PROC_EXT

    result = {'source': [], 'xml': [], 'sql': [], 'properties': [], 'proc': []}

    with correlation_id() as cid:
        _logger.info('scan_for_sql_files.start', extra={'root': project_root})
        for path in walk_files(project_root, extensions=all_ext,
                               exclude_dirs=exclude_dirs, exclude_ext=exclude_ext):
            category = classify_file(path, source_ext, xml_ext, sql_ext, props_ext)
            if category == 'sql':
                result['sql'].append(path)
            elif category == 'proc':
                # EXEC SQL is the reliable marker: a .pc file with only
                # WHENEVER / CONNECT / SQLCA still needs conversion even
                # when no SELECT/INSERT keyword appears.
                if _file_contains_proc(path) or _file_contains_sql(path):
                    result['proc'].append(path)
            elif category in ('source', 'xml', 'properties'):
                if _file_contains_sql(path):
                    result[category].append(path)
        for key in result:
            result[key].sort()
        _logger.info(
            'scan_for_sql_files done',
            extra={
                'source': len(result['source']),
                'xml': len(result['xml']),
                'sql': len(result['sql']),
                'properties': len(result['properties']),
                'proc': len(result['proc']),
                'correlation_id': cid,
            },
        )
    return result


def scan_for_sql_files(project_root: str) -> dict:
    """Walk the project root, index files that (probably) contain SQL, and
    write the index to a JSON Lines file on disk.

    Optimized for large projects: the full listing is written to disk
    and the tool returns a compact summary plus the output path.
    Callers read the jsonl file when they need individual paths.

    Output file layout (1 JSON object per line):
        {"category": "source"|"xml"|"sql"|"properties"|"proc", "path": "/abs/path"}

    Args:
        project_root: Absolute path to the project root.

    Returns:
        dict with keys:
          - ``output_path``: absolute path to the jsonl file
          - ``total``: total number of indexed files
          - ``counts``: {"source": N, "xml": N, "sql": N, "properties": N, "proc": N}
          - ``project_root``: resolved project root
          - ``large_scale_warning``: None, or a message recommending
            careful review when ``total >= 1000`` (SCAW2.0 has no CLI
            fallback — everything runs through the agent chat).
    """
    result = _scan(project_root)

    root_resolved = str(Path(project_root).resolve())
    root_hash = hashlib.md5(root_resolved.encode('utf-8')).hexdigest()[:12]
    out_path = Path(tempfile.gettempdir()) / f'scaw-scan-{root_hash}.jsonl'

    counts = {k: len(v) for k, v in result.items()}
    total = sum(counts.values())

    with open(out_path, 'w', encoding='utf-8') as f:
        for category in ('source', 'xml', 'sql', 'properties', 'proc'):
            for path in result.get(category, []):
                f.write(json.dumps({'category': category, 'path': path}) + '\n')

    large_scale_warning = None
    if total >= 1000:
        large_scale_warning = (
            f'{total} files matched — this is a large project. Consider '
            'reviewing and converting in smaller batches '
            'rather than processing everything at once.'
        )

    return {
        'output_path': str(out_path),
        'total': total,
        'counts': counts,
        'project_root': root_resolved,
        'large_scale_warning': large_scale_warning,
    }
