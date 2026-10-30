"""Write db track convert output in SCAW1.0's per-object directory format.

SCAW2.0はSCAW1.0の出力形式（``./result/<オブジェクト名>/``
ディレクトリ単位）を継承する。
"""
from __future__ import annotations

import os
import re

# Review-status values (tool-db-inventory-schema/SKILL.md) that count as a
# successful conversion for the purpose of choosing OK.txt vs NG.txt.
_OK_STATUSES = {'pass', 'no_change_needed', 'sct_already_handled'}


def _safe_dirname(object_name: str) -> str:
    """Turn a possibly schema-qualified object name into a filesystem-safe
    directory name.

    ``SCHEMA.PROC_NAME`` -> ``PROC_NAME`` (schema prefix dropped, matching
    SCAW1.0's ``result_dir_name`` convention in the retired
    ``multi_agent_processor.py``). Falls back to the full name (with
    non-alphanumeric characters replaced) if no schema separator is found.
    """
    name = object_name.strip()
    if '.' in name:
        parts = name.split('.')
        name = parts[-1]
    return re.sub(r'[^\w.-]', '_', name) or 'unnamed_object'


def write_db_result(
    result_dir: str,
    object_name: str,
    oracle_sql: str,
    postgres_sql: str,
    test_result: str = '',
    *,
    status: str = '',
    summary: str = '',
) -> dict:
    """Write one db-track conversion result to ``<result_dir>/<obj>/``.

    Args:
        result_dir: Base output directory (typically ``./result``).
        object_name: Target object name, e.g. ``SCHEMA.PROC_NAME``. The
            schema prefix is dropped when deriving the subdirectory name
            (SCAW1.0 convention).
        oracle_sql: Original Oracle DDL/PL-SQL source (from SCT
            ``converted.sql`` or user-provided text).
        postgres_sql: Converted PostgreSQL DDL/PL-pgSQL.
        test_result: Free-text summary of the simple execution test
            (run_ora_sql / run_postgres_sql). Empty string when no
            test was run.
        status: Review-status vocabulary value (see
            tool-db-inventory-schema/SKILL.md), e.g. ``"pass"``,
            ``"partial_by_llm"``, ``"fail"``. When given, this also
            decides whether ``OK.txt`` or ``NG.txt`` is written
            (SCAW1.0-derived summary format — see
            tool-output-layout/SKILL.md): ``pass`` / ``no_change_needed``
            / ``sct_already_handled`` -> ``OK.txt``; anything else
            (``partial_by_llm``, ``validator_limitation``,
            ``manual_review_range``, ``manual_review_bind``, ``fail``)
            -> ``NG.txt``. Leave empty (default) to skip writing a
            summary file entirely — backward compatible.
        summary: Free-text body for ``OK.txt`` / ``NG.txt``. The calling
            agent composes this, following the structure described in
            tool-output-layout/SKILL.md (status / target object /
            timestamp / main changes / test result counts / notes, plus
            failure reason / retry count / recommended action for NG).
            Ignored when ``status`` is empty. If ``status`` is given but
            ``summary`` is empty, a minimal placeholder body is written
            instead of failing.

    Returns:
        dict with ``object_dir`` (absolute path) and the file paths
        written: ``oracle_sql_path``, ``postgres_sql_path``,
        ``test_result_path``, and ``summary_path`` (``None`` when
        ``status`` was not given).
    """
    result_dir = os.path.abspath(result_dir)
    subdir = _safe_dirname(object_name)
    object_dir = os.path.join(result_dir, subdir)
    os.makedirs(object_dir, exist_ok=True)

    oracle_path = os.path.join(object_dir, 'oracle.sql')
    postgres_path = os.path.join(object_dir, 'postgres.sql')
    test_path = os.path.join(object_dir, 'test_result.txt')

    with open(oracle_path, 'w', encoding='utf-8') as f:
        f.write(oracle_sql or '')
    with open(postgres_path, 'w', encoding='utf-8') as f:
        f.write(postgres_sql or '')
    with open(test_path, 'w', encoding='utf-8') as f:
        f.write(test_result or '(no execution test recorded)\n')

    summary_path = None
    if status:
        is_ok = status in _OK_STATUSES
        summary_path = os.path.join(object_dir, 'OK.txt' if is_ok else 'NG.txt')
        with open(summary_path, 'w', encoding='utf-8') as f:
            f.write(summary or f'status: {status}\nobject: {object_name}\n')
        # Clear out a stale summary from an earlier attempt with the
        # opposite outcome (e.g. a retry that turned a prior NG into OK).
        other_path = os.path.join(object_dir, 'NG.txt' if is_ok else 'OK.txt')
        if os.path.exists(other_path):
            os.remove(other_path)

    return {
        'object_dir': object_dir,
        'oracle_sql_path': oracle_path,
        'postgres_sql_path': postgres_path,
        'test_result_path': test_path,
        'summary_path': summary_path,
    }


def list_converted_objects(result_dir: str) -> list[str]:
    """Return the object subdirectory names already present under
    ``result_dir`` (used by the "残りリスト" logic in the後半一括変換 flow).

    Returns an empty list when ``result_dir`` does not exist yet.
    """
    result_dir = os.path.abspath(result_dir)
    if not os.path.isdir(result_dir):
        return []
    return sorted(
        name for name in os.listdir(result_dir)
        if os.path.isdir(os.path.join(result_dir, name))
    )
