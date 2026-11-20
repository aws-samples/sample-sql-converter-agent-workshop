"""Write db track convert output in SCAW1.0's per-object directory format.

SCAW2.0はSCAW1.0の出力形式（``./result/<オブジェクト名>/``
ディレクトリ単位）を継承する。
"""
from __future__ import annotations

import os
import re
from datetime import datetime

# Review-status values (tool-review-status/SKILL.md) that count as a
# successful conversion for the purpose of choosing OK.txt vs NG.txt.
_OK_STATUSES = {'pass', 'no_change_needed', 'sct_already_handled'}

# The OK.txt / NG.txt template lives in the Skill so that people can change it
# in one place: the first fenced block after the heading below. Its "## ..."
# headings and "- <label>:" items are required in the summary; the section
# whose heading contains "NG.txt" is required only for NG.txt.
_TEMPLATE_PATH = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    '..', 'skills', 'tool-output-layout', 'SKILL.md',
)
_TEMPLATE_HEADING = 'OK.txt / NG.txt の雛形'
_LABEL_RE = re.compile(r'^\s*-\s*([^:：<]+?)\s*[:：]')


def _heading_core(line: str) -> str:
    """'## （NG.txtの場合のみ）失敗情報' -> '失敗情報'."""
    text = line.strip().lstrip('#').strip()
    return re.sub(r'[（(][^）)]*[）)]', '', text).strip()


def _load_template(path: str = _TEMPLATE_PATH) -> tuple[list, list] | None:
    """Return (common, ng_only) lists of ('heading'|'label', text), or None
    when the template cannot be found."""
    try:
        with open(path, encoding='utf-8') as f:
            text = f.read()
    except OSError:
        return None
    idx = text.find(_TEMPLATE_HEADING)
    if idx < 0:
        return None
    m = re.search(r'```[^\n]*\n(.*?)```', text[idx:], re.S)
    if not m:
        return None
    common, ng = [], []
    current = common
    for line in m.group(1).splitlines():
        if line.strip().startswith('## '):
            current = ng if 'NG.txt' in line else common
            current.append(('heading', _heading_core(line)))
            continue
        lm = _LABEL_RE.match(line)
        if lm:
            current.append(('label', lm.group(1)))
    return common, ng


def _missing_items(summary: str, is_ok: bool, template=None) -> list[str] | None:
    """List template headings / labels absent from ``summary``.
    Returns None when no template is available (no check)."""
    template = template if template is not None else _load_template()
    if template is None:
        return None
    common, ng = template
    required = common if is_ok else common + ng
    headings = {_heading_core(l) for l in summary.splitlines() if l.strip().startswith('## ')}
    labels = {m.group(1) for m in map(_LABEL_RE.match, summary.splitlines()) if m}
    missing = []
    for kind, text in required:
        if kind == 'heading' and text not in headings:
            missing.append(f'## {text}')
        elif kind == 'label' and text not in labels:
            missing.append(f'- {text}:')
    return missing


_KIND_RE = re.compile(
    r'\bCREATE\s+(?:OR\s+REPLACE\s+)?(?:EDITIONABLE\s+|NONEDITIONABLE\s+)?'
    r'(FUNCTION|PROCEDURE)\b', re.IGNORECASE)


def _routine_kind(sql: str) -> str | None:
    m = _KIND_RE.search(sql or '')
    return m.group(1).upper() if m else None


def _fill_timestamp(summary: str) -> str:
    """Overwrite the 実施日時 line with the actual time (the agent has no
    reliable clock and tends to guess a date)."""
    now = datetime.now().astimezone().strftime('%Y-%m-%d %H:%M:%S %Z')
    return re.sub(r'(^\s*-\s*実施日時\s*[:：]).*$', rf'\g<1> {now}', summary, count=1, flags=re.M)


def _safe_dirname(object_name: str) -> str:
    """Turn a possibly schema-qualified object name into a filesystem-safe
    directory name: ``SCHEMA.proc_name`` -> ``PROC_NAME``.

    The schema prefix is dropped (SCAW1.0 convention) and the name is
    upper-cased, so the same object always maps to the same directory
    whatever case the caller used (Oracle object names are upper case in
    the SCT / DMS SC CSVs). Non-alphanumeric characters are replaced.
    """
    name = object_name.strip().strip('"')
    if '.' in name:
        name = name.split('.')[-1].strip('"')
    return re.sub(r'[^\w.-]', '_', name).upper() or 'UNNAMED_OBJECT'


def _object_dir(result_dir: str, subdir: str) -> str:
    """Return the directory for ``subdir``. A directory written earlier with
    different letter case (for example ``proc_name``) is renamed to the
    upper-case name so that one object has only one directory."""
    target = os.path.join(result_dir, subdir)
    if os.path.isdir(result_dir) and not os.path.isdir(target):
        for name in os.listdir(result_dir):
            path = os.path.join(result_dir, name)
            if name != subdir and name.upper() == subdir and os.path.isdir(path):
                tmp = os.path.join(result_dir, f'.{name}.renaming')
                os.rename(path, tmp)  # two steps for case-insensitive file systems
                os.rename(tmp, target)
                break
    return target


def write_db_result(
    result_dir: str,
    object_name: str,
    oracle_sql: str,
    postgres_sql: str,
    test_result: str = '',
    *,
    status: str = '',
    summary: str = '',
    kind_change_reason: str = '',
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
            tool-review-status/SKILL.md), e.g. ``"pass"``,
            ``"partial_by_llm"``, ``"fail"``. When given, this also
            decides whether ``OK.txt`` or ``NG.txt`` is written:
            ``pass`` / ``no_change_needed``
            / ``sct_already_handled`` -> ``OK.txt``; anything else
            (``partial_by_llm``, ``validator_limitation``,
            ``manual_review_range``, ``manual_review_bind``, ``fail``)
            -> ``NG.txt``. Leave empty (default) to skip writing a
            summary file entirely — backward compatible.
        summary: Body for ``OK.txt`` / ``NG.txt``, composed by the agent
            from the template in tool-output-layout/SKILL.md. When a
            template heading or item label is missing, nothing is written
            and an ``error`` is returned so the agent can resend it.
            Ignored when ``status`` is empty. If ``status`` is given but
            ``summary`` is empty, a minimal placeholder body is written
            instead of failing.

    Returns:
        dict with ``object_dir`` (absolute path) and the file paths
        written: ``oracle_sql_path``, ``postgres_sql_path``,
        ``test_result_path``, and ``summary_path`` (``None`` when
        ``status`` was not given). When the summary is missing required
        headings: ``{"error": ..., "missing_headings": [...]}`` and no
        files are written.
    """
    src_kind, dst_kind = _routine_kind(oracle_sql), _routine_kind(postgres_sql)
    if src_kind and dst_kind and src_kind != dst_kind and not kind_change_reason.strip():
        return {
            'error': (
                f'オブジェクトの種類が {src_kind} から {dst_kind} に変わっています。呼び出し方と'
                '呼び出し元が変わるため、何も書き出していません。元の種類のまま変換し直すか、'
                '変える理由を kind_change_reason に書き、summary の注意事項にも書いてから、もう一度呼んでください。'
            ),
            'kind_change': [src_kind, dst_kind],
        }

    if status and summary:
        missing = _missing_items(summary, status in _OK_STATUSES)
        if missing:
            return {
                'error': (
                    'summary に必要な見出しまたは項目がありません。tool-output-layout の'
                    '「OK.txt / NG.txt の雛形」の見出しと項目名のまま summary を作り直して、'
                    'もう一度呼んでください。ファイルは書き出していません。'
                ),
                'missing_headings': missing,
            }

    result_dir = os.path.abspath(result_dir)
    os.makedirs(result_dir, exist_ok=True)
    object_dir = _object_dir(result_dir, _safe_dirname(object_name))
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
            f.write(_fill_timestamp(summary) if summary else f'status: {status}\nobject: {object_name}\n')
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
    """Return the object names already converted under ``result_dir``, in
    upper case (the directory naming rule of write_db_result), for the
    "残りリスト" logic in the後半一括変換 flow. Compare them with the target
    object names without the schema prefix, in upper case.

    Returns an empty list when ``result_dir`` does not exist yet.
    """
    result_dir = os.path.abspath(result_dir)
    if not os.path.isdir(result_dir):
        return []
    return sorted({
        name.upper() for name in os.listdir(result_dir)
        if os.path.isdir(os.path.join(result_dir, name)) and not name.startswith('.')
    })
