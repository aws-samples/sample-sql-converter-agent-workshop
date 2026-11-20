"""Canonical filename resolver for SCAW2.0 tool output artefacts.

SCAW2.0 only implements the convert phase, so only the kinds actually
used by SCAW2.0's tools (SCT parsing caches) are defined here.

Deterministic — no file I/O beyond path composition, no LLM.
"""
from __future__ import annotations

import os


_CANONICAL: dict[str, str] = {
    # SCT parsing caches (parse_sct_csv, parse_sct_converted_sql) — regenerable, safe to delete.
    'parse_sct_csv_cache': 'parse_sct_csv.json',
    'parse_sct_converted_sql_cache': 'parse_sct_converted_sql.json',
    # DMS Schema Conversion parsing cache — regenerable, safe to delete.
    'parse_dms_sc_converted_sql_cache': 'parse_dms_sc_converted_sql.json',
    # SCT assessment aggregate (parse_sct_csv output, consumed by db convert flow).
    'sct_assessment_json': 'sct_assessment.json',
}


_SUBDIR: dict[str, str] = {
    'parse_sct_csv_cache': '.cache',
    'parse_sct_converted_sql_cache': '.cache',
    'parse_dms_sc_converted_sql_cache': '.cache',
    'sct_assessment_json': 'json',
}


def resolve_report_filename(
    kind: str,
    user_supplied: str | None = None,
) -> dict:
    """Return the filename and subdir a caller should use for ``kind``.

    SCAW2.0 has no override-allowed kinds (no report markdown), so
    ``user_supplied`` is always ignored and ``is_user_supplied`` is
    always False.

    Args:
        kind: One of the keys in the canonical table. Unknown kinds
            raise ``ValueError``.
        user_supplied: Accepted for interface compatibility; always
            ignored in SCAW2.0.

    Returns:
        ``{"filename": str, "subdir": str, "is_user_supplied": bool,
           "is_canonical": bool, "canonical_filename": str}``.
    """
    if kind not in _CANONICAL:
        raise ValueError(
            f'unknown report filename kind: {kind!r} '
            f'(known: {sorted(_CANONICAL)})'
        )
    canonical = _CANONICAL[kind]
    subdir = _SUBDIR[kind]
    return {
        'filename': canonical,
        'subdir': subdir,
        'is_user_supplied': False,
        'is_canonical': True,
        'canonical_filename': canonical,
    }


def resolve_report_path(
    out_dir: str,
    kind: str,
    user_supplied: str | None = None,
) -> str:
    """Return the full path ``<out_dir>/<subdir>/<filename>``.

    Callers are responsible for
    ``os.makedirs(os.path.dirname(path), exist_ok=True)`` before
    writing.
    """
    out_dir = os.path.abspath(out_dir)
    resolved = resolve_report_filename(kind, user_supplied)
    subdir = resolved['subdir']
    if subdir:
        return os.path.join(out_dir, subdir, resolved['filename'])
    return os.path.join(out_dir, resolved['filename'])
