"""Write app-convert diff/patch outputs.

SCAW2.0 has no assess/report phase, so this module writes only the
diff/patch/inplace outputs (no CSV inventory or narrative report).

Apply modes (mirror ``source_patcher.PatchMode``):

- ``inplace``: patches source files in place; no side files.
- ``diff``: writes per-file unified diffs to ``<out_dir>/diffs/...``;
  source files are untouched.
- ``patch``: writes a single unified ``<out_dir>/app-conversion.patch``;
  source files are untouched.
"""
from __future__ import annotations

import json
import os
from collections import Counter
from pathlib import Path

import source_patcher

_DIFFS_DIRNAME = 'diffs'
_PATCH_NAME = 'app-conversion.patch'


def write_app_convert_outputs(
    out_dir: str,
    output_items: list[dict] | None = None,
    per_file_replacements: dict | None = None,
    project_root: str = '',
    mode: str = 'diff',
    *,
    output_items_path: str | None = None,
    per_file_replacements_path: str | None = None,
) -> dict:
    """Write app-convert diff/patch outputs.

    Args:
        out_dir: Directory to write into. Created if missing.
        output_items: One dict per converted item (used only to
            compute ``review_status_distribution`` for the caller's
            chat summary; not written to disk in this version).
            Mutually exclusive with ``output_items_path``.
        per_file_replacements: Dict of
            ``{absolute_filepath: [source_patcher.Replacement, ...]}``.
            Mutually exclusive with ``per_file_replacements_path``.
        project_root: Absolute project root — diff paths are made
            relative to this directory.
        mode: ``'inplace'`` / ``'diff'`` / ``'patch'``.
        output_items_path: Path to a JSON file containing the items
            list (bare list or dict with ``items``/``rows`` key).
        per_file_replacements_path: Path to a JSON file containing
            the per-file replacements dict.

    Returns:
        ``{"patch_path": str | None,
          "diffs_dir": str | None,
          "files_patched": int,
          "review_status_distribution": dict[str, int]}``.
    """
    if output_items is not None and output_items_path:
        raise ValueError(
            'write_app_convert_outputs: pass either output_items '
            'or output_items_path, not both.'
        )
    if output_items_path:
        with open(output_items_path, encoding='utf-8') as _f:
            _loaded = json.load(_f)
        if isinstance(_loaded, list):
            output_items = _loaded
        elif isinstance(_loaded, dict):
            for k in ('items', 'rows', 'records'):
                if k in _loaded and isinstance(_loaded[k], list):
                    output_items = _loaded[k]
                    break
            else:
                raise ValueError(
                    'write_app_convert_outputs: output_items_path '
                    f'{output_items_path!r} must contain a list '
                    'or a dict with "items"/"rows"/"records" key.'
                )
        else:
            raise ValueError(
                'write_app_convert_outputs: output_items_path '
                f'{output_items_path!r} must contain a list or dict.'
            )
    output_items = output_items or []

    if per_file_replacements is not None and per_file_replacements_path:
        raise ValueError(
            'write_app_convert_outputs: pass either '
            'per_file_replacements or per_file_replacements_path, '
            'not both.'
        )
    if per_file_replacements is None and not per_file_replacements_path:
        per_file_replacements = {}
    if per_file_replacements_path:
        with open(per_file_replacements_path, encoding='utf-8') as _f:
            _loaded_repl = json.load(_f)
        if not isinstance(_loaded_repl, dict):
            raise ValueError(
                'write_app_convert_outputs: per_file_replacements_path '
                f'{per_file_replacements_path!r} must contain a dict '
                '{filepath: [replacement dict, ...], ...}.'
            )
        per_file_replacements = {}
        for fp, repls in _loaded_repl.items():
            if not isinstance(repls, list):
                raise ValueError(
                    'write_app_convert_outputs: per_file_replacements_path '
                    f'value for {fp!r} must be a list.'
                )
            per_file_replacements[fp] = [
                source_patcher.Replacement(
                    start_line=r['start_line'],
                    end_line=r['end_line'],
                    new_text=r['new_text'],
                ) for r in repls
            ]

    out_dir = os.path.abspath(out_dir)
    os.makedirs(out_dir, exist_ok=True)

    patch_mode = _coerce_mode(mode)
    patch_path = None
    if patch_mode == source_patcher.PatchMode.PATCH:
        patch_path = os.path.join(out_dir, _PATCH_NAME)
        # Truncate so repeated runs don't accumulate duplicate hunks.
        open(patch_path, 'w').close()

    diffs_dir = None
    if patch_mode == source_patcher.PatchMode.DIFF:
        diffs_dir = os.path.join(out_dir, _DIFFS_DIRNAME)

    files_patched = 0
    for filepath, replacements in per_file_replacements.items():
        result = source_patcher.apply_to_file(
            filepath, replacements, mode=patch_mode,
            project_root=project_root, patch_file=patch_path,
        )
        if result.changed:
            files_patched += 1
            if patch_mode == source_patcher.PatchMode.DIFF and result.diff:
                rel = os.path.relpath(filepath, project_root)
                diff_path = os.path.join(out_dir, _DIFFS_DIRNAME, rel + '.diff')
                os.makedirs(os.path.dirname(diff_path), exist_ok=True)
                Path(diff_path).write_text(result.diff, encoding='utf-8')

    dist = dict(Counter(it.get('review_status', 'not processed')
                        for it in output_items))

    return {
        'patch_path': patch_path,
        'diffs_dir': diffs_dir,
        'files_patched': files_patched,
        'review_status_distribution': dist,
    }


def _coerce_mode(mode: str) -> source_patcher.PatchMode:
    """Accept either a string (``'diff'`` / ``'inplace'`` / ``'patch'``)
    or a ``PatchMode`` enum instance."""
    if isinstance(mode, source_patcher.PatchMode):
        return mode
    mapping = {
        'inplace': source_patcher.PatchMode.INPLACE,
        'diff': source_patcher.PatchMode.DIFF,
        'patch': source_patcher.PatchMode.PATCH,
    }
    try:
        return mapping[mode]
    except KeyError:
        raise ValueError(
            f'unknown apply mode: {mode!r} '
            f'(expected inplace/diff/patch)'
        )
