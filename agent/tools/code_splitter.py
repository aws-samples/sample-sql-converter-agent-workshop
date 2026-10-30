"""Split SCT-converted DDL into per-object blocks and extract snippets.
"""

import re
from dataclasses import dataclass

from logging_setup import correlation_id, get_logger


_logger = get_logger('tools.code_splitter')

_OBJECT_KINDS = (
    'TABLE|FUNCTION|PROCEDURE|VIEW|TRIGGER|SEQUENCE|DOMAIN|TYPE|SCHEMA|'
    'PACKAGE(?:\\s+BODY)?|MATERIALIZED\\s+VIEW|SYNONYM|DATABASE\\s+LINK|'
    '(?:UNIQUE\\s+)?INDEX'
)

# Matches a full CREATE statement up to the next CREATE / "-- ---- Write" marker / EOF
_CREATE_BLOCK_RE = re.compile(
    rf'^(CREATE\s+(?:OR\s+REPLACE\s+)?(?:FORCE\s+)?(?:{_OBJECT_KINDS})\s+.*?)'
    r'(?=^CREATE\s|^--\s+-+\s+Write\s|\Z)',
    re.MULTILINE | re.DOTALL | re.IGNORECASE,
)

_NAME_MAIN_RE = re.compile(
    rf'CREATE\s+(?:OR\s+REPLACE\s+)?(?:FORCE\s+)?'
    rf'(?:{_OBJECT_KINDS.replace("|TRIGGER", "")})\s+'
    r'(?:IF\s+NOT\s+EXISTS\s+)?'
    r'("?\w+"?(?:\."?\w+(?:\$\w+)*"?)+)',
    re.IGNORECASE,
)
_NAME_TRIGGER_RE = re.compile(
    r'CREATE\s+TRIGGER\s+"?(\w+(?:\$\w+)*)"?',
    re.IGNORECASE,
)

_SIGNATURE_BOUNDARY_RE = re.compile(r'^\s*(BEGIN|AS)\s*$', re.IGNORECASE)


@dataclass(frozen=True)
class SplitObject:
    """A single CREATE ... block from the DDL."""
    name: str        # lowercase, qualified when possible
    code: str        # full CREATE block text


def split_objects(sql_path: str) -> list[SplitObject]:
    """Parse ``sql_path`` and extract per-object CREATE blocks.

    Multiple blocks with the same qualified name are concatenated.
    """
    with correlation_id() as cid:
        _logger.info('split_objects.start', extra={'path': sql_path})
        with open(sql_path, 'r', encoding='utf-8-sig') as f:
            content = f.read()

        blocks: dict[str, str] = {}
        for m in _CREATE_BLOCK_RE.finditer(content):
            block = m.group(1).strip()
            name = _extract_object_name(block)
            if name:
                blocks[name] = (blocks[name] + '\n\n' + block) if name in blocks else block

        results = [SplitObject(name=n, code=c) for n, c in blocks.items()]
        _logger.info('split_objects.done',
                     extra={'objects': len(results), 'correlation_id': cid})
        return results


def _extract_object_name(block: str) -> str | None:
    """Extract the qualified object name from the first line of a CREATE block."""
    first_line = block.split('\n', 1)[0].strip()
    m = _NAME_MAIN_RE.match(first_line)
    if m:
        return m.group(1).lower().replace('"', '')
    m = _NAME_TRIGGER_RE.match(first_line)
    if m:
        return m.group(1).lower()
    return None


def extract_snippets(code: str, action_item_ids: list[str],
                     *, context_lines: int = 20) -> str:
    """Extract signature + snippets around SCT markers.

    Used for large objects: send the LLM only the function signature
    plus a window around each SCT Action Item marker instead of the
    full body. Useful for interactively splitting an object that is too
    large to send whole.
    """
    lines = code.splitlines()
    if not lines or not action_item_ids:
        return code

    sig_lines = _signature_line_indices(lines)
    marker_pattern = re.compile(
        r'\[(' + '|'.join(re.escape(aid) for aid in action_item_ids) + r')\s*-\s*Severity'
    )
    target_lines: set[int] = set()
    for i, line in enumerate(lines):
        if marker_pattern.search(line):
            start = max(0, i - context_lines)
            end = min(len(lines), i + context_lines + 1)
            target_lines.update(range(start, end))

    if not target_lines:
        return code

    include = sorted(sig_lines | target_lines)
    return _render_with_gaps(lines, include)


def _signature_line_indices(lines: list[str]) -> set[int]:
    """Indices of lines from start through the first BEGIN/AS line (inclusive)."""
    sig_end = 0
    for i, line in enumerate(lines):
        sig_end = i
        if _SIGNATURE_BOUNDARY_RE.match(line):
            break
    return set(range(0, sig_end + 1))


def _render_with_gaps(lines: list[str], include_indices: list[int]) -> str:
    """Stitch included lines back together, emitting ``-- ... (N omitted)`` markers."""
    out: list[str] = []
    prev = -1
    for i in include_indices:
        if prev >= 0 and i > prev + 1:
            out.append(f'    -- ... ({i - prev - 1} lines omitted) ...')
        out.append(lines[i])
        prev = i
    if include_indices and include_indices[-1] < len(lines) - 1:
        trailing = len(lines) - 1 - include_indices[-1]
        out.append(f'    -- ... ({trailing} lines omitted) ...')
    return '\n'.join(out)


_ROUTINE_HEADER_RE_TEMPLATE = (
    r'^[ \t]*(?:OVERRIDING\s+|STATIC\s+|MEMBER\s+)?'
    r'(?:FUNCTION|PROCEDURE|CURSOR|TYPE)\s+"?{name}"?\s*[(\sI]'
)


def extract_routine_snippet(package_code: str, routine_name: str) -> str:
    """Extract one FUNCTION/PROCEDURE body from a PACKAGE (BODY) source.

    ``split_objects`` merges an entire ``PACKAGE`` + ``PACKAGE BODY``
    pair into a single object keyed by the package's qualified name.
    Per-routine targets need just the one routine's body — sending
    the whole package could exceed the LLM prompt budget for packages
    with dozens of routines.

    Args:
        package_code: Full merged PACKAGE + PACKAGE BODY source, as
            returned by ``split_objects``.
        routine_name: Bare routine name (no schema/package prefix).

    Returns:
        The matched routine's source text, or ``''`` if no header
        matching ``routine_name`` is found.
    """
    if not package_code or not routine_name:
        return ''

    header_re = re.compile(
        _ROUTINE_HEADER_RE_TEMPLATE.format(name=re.escape(routine_name)),
        re.IGNORECASE | re.MULTILINE,
    )
    matches = list(header_re.finditer(package_code))
    if not matches:
        return ''

    next_header_re = re.compile(
        r'^[ \t]*(?:OVERRIDING\s+|STATIC\s+|MEMBER\s+)?'
        r'(?:FUNCTION|PROCEDURE|CURSOR|TYPE)\s+"?\w+"?\s*[(\sI]',
        re.IGNORECASE | re.MULTILINE,
    )

    def _body_for(m: re.Match) -> str:
        start = m.start()
        next_m = next_header_re.search(package_code, m.end())
        end = next_m.start() if next_m else len(package_code)
        return package_code[start:end].strip()

    best = None
    for m in matches:
        body = _body_for(m)
        if re.search(r'^\s*BEGIN\b', body, re.IGNORECASE | re.MULTILINE):
            best = body
        elif best is None and body:
            best = body
    if best is None:
        best = _body_for(matches[-1])
    return best
