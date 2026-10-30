"""Apply SQL conversions to source files with 3 output modes.
"""

import difflib
import os
import shutil
from dataclasses import dataclass
from enum import Enum
from typing import Iterable, Optional

from logging_setup import correlation_id, get_logger
from convert_oracle_sql_rules import apply_rules


_logger = get_logger('tools.source_patcher')


class PatchMode(str, Enum):
    """Output mode for applied conversions."""
    DIFF = 'diff'         # return unified diff text (caller writes to stdout)
    PATCH = 'patch'       # write unified diff to a patch file
    INPLACE = 'inplace'   # overwrite source file (creates .bak)


@dataclass(frozen=True)
class Replacement:
    """A line-range replacement within a file.

    ``start_line`` and ``end_line`` are 1-based inclusive. ``new_text`` is the
    converted content to substitute for that range. If None, A-class rule
    conversion (``apply_rules``) is applied line-by-line instead.
    """
    start_line: int
    end_line: int
    new_text: Optional[str] = None


@dataclass
class PatchResult:
    """Outcome of applying replacements to a single file."""
    filepath: str
    mode: PatchMode
    changed: bool
    hunk_count: int
    diff: str = ''              # unified diff text (always populated)
    patch_file: Optional[str] = None  # path of written .patch (PATCH mode)
    backup_file: Optional[str] = None  # path of .bak (INPLACE mode)


# ---- Pure helpers -----------------------------------------------------------

def patch_lines(lines: list[str], replacements: Iterable[Replacement]) -> list[str]:
    """Apply ``replacements`` to ``lines``. Returns a new list.

    Replacements are applied from bottom to top so earlier line numbers stay
    valid. Each replacement either substitutes ``new_text`` for the range or,
    when ``new_text`` is None, applies rule-based conversion per line.
    """
    result = list(lines)
    for rep in sorted(replacements, key=lambda r: r.start_line, reverse=True):
        s = rep.start_line - 1
        e = min(rep.end_line, len(result))
        if rep.new_text is None:
            for i in range(s, e):
                result[i] = apply_rules(result[i])
        else:
            new_lines = rep.new_text.splitlines(keepends=True)
            if new_lines and not new_lines[-1].endswith('\n'):
                new_lines[-1] += '\n'
            result[s:e] = new_lines
    return result


def diff_lines(original: list[str], converted: list[str], relpath: str) -> str:
    """Unified diff between ``original`` and ``converted``. Empty if identical."""
    return ''.join(difflib.unified_diff(
        original, converted,
        fromfile=f'a/{relpath}',
        tofile=f'b/{relpath}',
    ))


# ---- File-level operation ---------------------------------------------------

def apply_to_file(filepath: str, replacements: Iterable[Replacement],
                  mode: PatchMode, *,
                  project_root: Optional[str] = None,
                  patch_file: Optional[str] = None) -> PatchResult:
    """Apply ``replacements`` to ``filepath`` using ``mode``.

    Args:
        filepath: Path to the source file.
        replacements: Line-range replacements to apply.
        mode: Output mode (DIFF / PATCH / INPLACE).
        project_root: When given, diff headers use paths relative to it.
        patch_file: Required in PATCH mode — destination for the .patch file.
                    Content is appended (multiple calls accumulate).

    Returns:
        PatchResult describing the outcome.
    """
    with correlation_id() as cid:
        reps = list(replacements)
        _logger.info('apply_to_file.start',
                     extra={'file': filepath, 'mode': mode.value,
                            'hunks': len(reps)})
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                original = f.readlines()
        except OSError as e:
            _logger.warning('read.failed', extra={'file': filepath, 'error': str(e)})
            return PatchResult(filepath=filepath, mode=mode,
                               changed=False, hunk_count=0)

        converted = patch_lines(original, reps)
        changed = converted != original
        relpath = (os.path.relpath(filepath, project_root)
                   if project_root else filepath)
        diff_text = diff_lines(original, converted, relpath) if changed else ''

        result = PatchResult(
            filepath=filepath, mode=mode,
            changed=changed, hunk_count=len(reps), diff=diff_text,
        )

        if not changed:
            _logger.info('apply_to_file.done',
                         extra={'file': filepath, 'changed': False,
                                'correlation_id': cid})
            return result

        if mode is PatchMode.DIFF:
            pass  # caller consumes result.diff
        elif mode is PatchMode.PATCH:
            if not patch_file:
                raise ValueError('mode=PATCH requires patch_file argument')
            os.makedirs(os.path.dirname(patch_file) or '.', exist_ok=True)
            with open(patch_file, 'a', encoding='utf-8') as f:
                f.write(diff_text)
            result.patch_file = patch_file
        elif mode is PatchMode.INPLACE:
            backup = filepath + '.bak'
            shutil.copy2(filepath, backup)
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(converted)
            result.backup_file = backup

        _logger.info('apply_to_file.done',
                     extra={'file': filepath, 'changed': True,
                            'mode': mode.value, 'hunks': len(reps),
                            'correlation_id': cid})
        return result
