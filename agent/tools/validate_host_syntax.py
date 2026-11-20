"""Host-language syntax validation for converted source fragments.

Uses ``tree_sitter_language_pack`` parsers. Validates that the LLM's
``converted_lines`` does not introduce any NEW syntax errors within the
[start_line, end_line] range — errors that already existed in the
original file before conversion are ignored (baseline tolerance).

Supported languages (by file extension):
  .java  → java       .py            → python
  .js    → javascript .ts/.tsx       → typescript
  .php   → php        .rb            → ruby
  .cs    → csharp     .c/.h          → c
  .cpp/.hpp/.cc/.hh → cpp            .xml → xml
  .vb    → vb
"""
from __future__ import annotations

import os
from typing import Optional


_EXT_TO_LANG = {
    '.java': 'java',
    '.py': 'python',
    '.js': 'javascript',
    '.mjs': 'javascript',
    '.cjs': 'javascript',
    '.ts': 'typescript',
    '.tsx': 'typescript',
    '.php': 'php',
    '.rb': 'ruby',
    '.cs': 'csharp',
    '.c': 'c',
    '.h': 'c',
    '.cpp': 'cpp',
    '.cc': 'cpp',
    '.cxx': 'cpp',
    '.hpp': 'cpp',
    '.hh': 'cpp',
    '.xml': 'xml',
    '.vb': 'vb',
}


def _detect_language(filepath: str) -> Optional[str]:
    ext = os.path.splitext(filepath)[1].lower()
    return _EXT_TO_LANG.get(ext)


def _errors_in_range(tree, start_line: int, end_line: int) -> list:
    """Return ERROR / missing nodes whose start row is within
    ``[start_line-1, end_line-1]`` (0-based inclusive)."""
    out: list = []
    root_node = tree.root_node if hasattr(tree, 'root_node') else tree

    def walk(node):
        is_err = node.type == 'ERROR' or getattr(node, 'is_missing', False)
        if is_err:
            r = node.start_point[0]
            if start_line - 1 <= r <= end_line - 1:
                text = b''
                try:
                    text = node.text or b''
                except Exception:
                    pass
                out.append({
                    'row': r + 1,
                    'col': node.start_point[1],
                    'text': text[:120].decode('utf-8', errors='replace'),
                })
        for c in node.children:
            walk(c)

    walk(root_node)
    return out


def validate_host_syntax(
    filepath: str,
    converted_lines: list,
    start_line: int,
    end_line: int,
) -> dict:
    """Return {status, language, error, newly_introduced}.

    status:
      - ``pass``    — no new syntax errors in the converted range.
      - ``fail``    — at least one new syntax error introduced.
      - ``skipped`` — language unsupported or file unreadable; caller
                      treats this as non-blocking.

    The tool parses the full file (original + converted-range
    substitution) so fragment artefacts such as a lone ``<select>`` or a
    half-branch ``if`` block do not produce false positives. Errors that
    exist in the baseline (original file) at the same (row, text) are
    dropped from the report.
    """
    lang = _detect_language(filepath)
    if not lang:
        return {'status': 'skipped', 'language': '',
                'error': 'unsupported extension', 'newly_introduced': []}

    try:
        from tree_sitter_language_pack import get_parser
        parser = get_parser(lang)
    except Exception as exc:  # noqa: BLE001
        return {'status': 'skipped', 'language': lang,
                'error': f'parser unavailable: {exc}', 'newly_introduced': []}

    try:
        with open(filepath, 'rb') as f:
            orig_bytes = f.read()
    except OSError as exc:
        return {'status': 'skipped', 'language': lang,
                'error': f'cannot read file: {exc}', 'newly_introduced': []}

    orig_text = orig_bytes.decode('utf-8', errors='replace')
    orig_lines = orig_text.splitlines(keepends=True)

    # Baseline: parse the original file; keep only ERROR nodes within range.
    orig_tree = parser.parse(orig_bytes)
    baseline = _errors_in_range(orig_tree, start_line, end_line)
    baseline_set = {(e['row'], e['text']) for e in baseline}

    # Apply converted_lines to the source range and re-parse.
    if end_line > len(orig_lines) or start_line < 1 or start_line > end_line:
        return {'status': 'skipped', 'language': lang,
                'error': f'range [{start_line},{end_line}] invalid for {len(orig_lines)}-line file',
                'newly_introduced': []}

    new_lines_str = list(orig_lines)
    # Ensure each converted line ends with '\n' so line bookkeeping holds.
    norm = [(ln if ln.endswith('\n') else ln + '\n') for ln in converted_lines]
    new_lines_str[start_line - 1:end_line] = norm
    new_bytes = ''.join(new_lines_str).encode('utf-8')
    new_tree = parser.parse(new_bytes)
    new_errors = _errors_in_range(new_tree, start_line,
                                  start_line - 1 + len(norm))

    newly_introduced = [
        e for e in new_errors if (e['row'], e['text']) not in baseline_set
    ]
    if newly_introduced:
        first = newly_introduced[0]
        return {
            'status': 'fail',
            'language': lang,
            'error': f'L{first["row"]}: {first["text"].strip()[:80]}',
            'newly_introduced': newly_introduced,
        }
    return {'status': 'pass', 'language': lang, 'error': '',
            'newly_introduced': []}
