"""Write app-convert outputs.

Apply modes:

- ``file`` (default): ``<out_dir>/converted/<relative path>`` (the whole
  converted file), ``<out_dir>/diffs/<relative path>.diff``, and, directly
  under ``<out_dir>``, the tests and the summary for the whole directory:
  ``oracle_test.sql`` / ``oracle_test.txt`` / ``postgres_test.sql`` /
  ``postgres_test.txt`` / ``comparison_result.txt`` and ``OK.txt`` or
  ``NG.txt``. Per-file results are kept in ``<out_dir>/.scaw-results.json``
  and the directory-level files are rebuilt from all of them on every call,
  so a project may be written in several calls or by parallel sub-agents.
  Source files are untouched.
- ``inplace``: patches source files in place; no side files.
- ``diff``: writes per-file unified diffs to ``<out_dir>/diffs/...``;
  source files are untouched.
- ``patch``: writes a single unified ``<out_dir>/app-conversion.patch``;
  source files are untouched.
"""
from __future__ import annotations

import hashlib
import json
import os
import re
import sys
import time
from collections import Counter
from pathlib import Path

import source_patcher
from _result_files import TEST_FILES as _TEST_KEYS, write_summary, write_test_files
from write_db_result import _OK_STATUSES, _fill_timestamp, _missing_items
from validate_bind_integrity import compare_host_placeholders, dollar_to_hash_names
from validate_host_syntax import validate_host_syntax

_DIFFS_DIRNAME = 'diffs'
_CONVERTED_DIRNAME = 'converted'
_RESULTS_STATE = '.scaw-results.json'
_LOCK_NAME = '.scaw-lock'
_FILE_MODE = 'file'
_PATCH_NAME = 'app-conversion.patch'

# Written by run_ora_sql / run_postgres_sql (agent/mcpserver/server.py), one
# file per chat session. All MCP servers of a session (including those of
# parallel sub-agents) share it, so the check is "both databases were run
# successfully in this session within the last _TEST_WINDOW_SEC".
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from utils.session import exec_log_path  # noqa: E402

_TEST_WINDOW_SEC = 30 * 60


def _executed_recently() -> set[str]:
    since = time.time() - _TEST_WINDOW_SEC
    dbs = set()
    try:
        with open(exec_log_path(), encoding='utf-8') as f:
            for line in f:
                try:
                    rec = json.loads(line)
                except ValueError:
                    continue
                if rec.get('ts', 0) >= since:
                    dbs.add(rec.get('db'))
    except OSError:
        pass
    return dbs


_STATE_NAME = '.scaw-replacements.json'


def _file_sha(path: str) -> str:
    try:
        with open(path, 'rb') as f:
            return hashlib.sha256(f.read()).hexdigest()
    except OSError:
        return ''


def _load_state(out_dir: str) -> tuple[dict, list[str]]:
    """Return (replacements per file, files whose stored replacements were
    dropped because the source file changed since they were stored)."""
    try:
        with open(os.path.join(out_dir, _STATE_NAME), encoding='utf-8') as f:
            data = json.load(f)
    except (OSError, ValueError):
        return {}, []
    state, dropped = {}, []
    for fp, entry in (data.items() if isinstance(data, dict) else []):
        if not isinstance(entry, dict) or entry.get('sha256') != _file_sha(fp):
            dropped.append(fp)
            continue
        try:
            state[fp] = [source_patcher.Replacement(**r) for r in entry.get('replacements', [])]
        except TypeError:
            dropped.append(fp)
    return state, dropped


def _save_state(out_dir: str, state: dict) -> None:
    data = {fp: {'sha256': _file_sha(fp),
                 'replacements': [{'start_line': r.start_line, 'end_line': r.end_line,
                                   'new_text': r.new_text} for r in reps]}
            for fp, reps in state.items()}
    with open(os.path.join(out_dir, _STATE_NAME), 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=1)


# Oracle constructs that should not remain in converted SQL. Checked on the
# whole converted file so that SQL the agent did not touch is reported too.
_ORACLE_RESIDUALS = [
    ('NVL / NVL2', re.compile(r'\bNVL2?\s*\(', re.I)),
    ('DECODE', re.compile(r'\bDECODE\s*\(', re.I)),
    ('ROWNUM', re.compile(r'\bROWNUM\b', re.I)),
    ('(+) outer join', re.compile(r'\(\s*\+\s*\)')),
    ('SYSDATE / SYSTIMESTAMP', re.compile(r'(?<![\w.])(?:SYSDATE|SYSTIMESTAMP)\b', re.I)),
    ('FROM DUAL', re.compile(r'\bFROM\s+DUAL\b', re.I)),
    ('MINUS', re.compile(r'\bMINUS\b', re.I)),
    ('CONNECT BY', re.compile(r'\bCONNECT\s+BY\b', re.I)),
    ('PIVOT', re.compile(r'\bPIVOT\s*\(', re.I)),
    ('LISTAGG', re.compile(r'\bLISTAGG\s*\(', re.I)),
    ('REGEXP_SUBSTR', re.compile(r'\bREGEXP_SUBSTR\s*\(', re.I)),
]
_COMMENT_LINE = re.compile(r'^\s*(?:<!--|--|//|/\*|\*|#)')


def _remaining_oracle(path: str, lines: list[str], limit: int = 50) -> list[dict]:
    found = []
    for n, line in enumerate(lines, 1):
        if _COMMENT_LINE.match(line):
            continue
        for label, rx in _ORACLE_RESIDUALS:
            if rx.search(line):
                found.append({'file': path, 'line': n, 'construct': label, 'text': line.strip()[:200]})
                break
        if len(found) >= limit:
            break
    return found


def _overlaps(a, b) -> bool:
    return a.start_line <= b.end_line and b.start_line <= a.end_line


def _overlap_errors(per_file: dict) -> list[dict]:
    errors = []
    for fp, reps in per_file.items():
        ordered = sorted(reps, key=lambda r: r.start_line)
        for x, y in zip(ordered, ordered[1:]):
            if _overlaps(x, y):
                errors.append({'file': fp, 'issue': (
                    f'lines {x.start_line}-{x.end_line} and {y.start_line}-{y.end_line} overlap')})
    return errors


def _merge(old: list, new: list) -> list:
    """Earlier replacements for the same file are kept unless a new one
    overlaps them (the new one wins)."""
    kept = [o for o in old if not any(_overlaps(o, n) for n in new)]
    return sorted(kept + list(new), key=lambda r: r.start_line)


def _to_replacement(r) -> source_patcher.Replacement:
    """Accept a Replacement, or a dict with ``start_line`` / ``end_line`` and
    either ``new_text`` (str) or ``converted_lines`` (list of str)."""
    if isinstance(r, source_patcher.Replacement):
        return r
    if not isinstance(r, dict) or 'start_line' not in r or 'end_line' not in r:
        raise ValueError(
            'write_app_convert_outputs: each replacement must be a dict with '
            '"start_line", "end_line" and "new_text" (or "converted_lines").'
        )
    new_text = r.get('new_text')
    if new_text is None and r.get('converted_lines') is not None:
        lines = list(r['converted_lines'])
        new_text = ''.join(
            line if line.endswith('\n') else line + '\n' for line in lines
        )
    return source_patcher.Replacement(
        start_line=int(r['start_line']),
        end_line=int(r['end_line']),
        new_text=new_text,
    )


def _check_placeholders(per_file: dict) -> tuple[list[dict], list[dict]]:
    """Compare each replacement with the original lines it replaces.
    Returns (errors, dollar_to_hash) where the second lists allowed
    MyBatis ${x} -> #{x} changes."""
    errors, moved = [], []
    for fp, repls in per_file.items():
        if not os.path.isfile(fp):
            continue
        with open(fp, encoding='utf-8') as f:
            lines = f.readlines()
        for r in repls:
            if r.new_text is None:
                continue
            original = ''.join(lines[r.start_line - 1:r.end_line])
            for issue in compare_host_placeholders(original, r.new_text):
                errors.append({
                    'file': fp, 'start_line': r.start_line, 'end_line': r.end_line,
                    **issue,
                    # Shown so the caller can spot wrong line numbers.
                    'original_lines': original[:400],
                })
            names = dollar_to_hash_names(original, r.new_text)
            if names:
                moved.append({'file': fp, 'start_line': r.start_line,
                              'end_line': r.end_line, 'names': names})
    return errors, moved


def _check_host_syntax(per_file: dict) -> tuple[list[dict], dict]:
    """Parse each file with tree-sitter before and after each replacement and
    report syntax errors that the replacement introduces (errors already in
    the original file are ignored). Returns (errors, checked) where
    ``checked`` maps file -> 'pass' / 'skipped: <reason>'. Files whose
    language or parser is unavailable are skipped (not blocking)."""
    errors, checked = [], {}
    for fp, repls in per_file.items():
        if not os.path.isfile(fp):
            continue
        for r in repls:
            if r.new_text is None:
                continue
            res = validate_host_syntax(
                fp, r.new_text.splitlines(), r.start_line, r.end_line)
            status = res.get('status')
            if status == 'fail':
                errors.append({
                    'file': fp, 'start_line': r.start_line, 'end_line': r.end_line,
                    'language': res.get('language', ''), 'error': res.get('error', ''),
                    'newly_introduced': res.get('newly_introduced', [])[:5],
                })
            elif status == 'skipped':
                checked.setdefault(fp, f"skipped: {res.get('error', '')}")
            else:
                checked.setdefault(fp, 'pass')
    return errors, checked


def _normalize_replacements(per_file: dict, project_root: str) -> dict:
    """Convert values to Replacement objects and make file paths absolute
    (relative paths are resolved against ``project_root``)."""
    normalized = {}
    for fp, repls in per_file.items():
        if not isinstance(repls, list):
            raise ValueError(
                f'write_app_convert_outputs: value for {fp!r} must be a list.'
            )
        path = fp
        if not os.path.isabs(path) and project_root:
            path = os.path.join(project_root, path)
        normalized[os.path.abspath(path)] = [_to_replacement(r) for r in repls]
    return normalized


def write_app_convert_outputs(
    out_dir: str,
    output_items: list[dict] | None = None,
    per_file_replacements: dict | None = None,
    project_root: str = '',
    mode: str = _FILE_MODE,
    *,
    per_file_results: dict | None = None,
    test_skipped_reason: str = '',
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
        test_skipped_reason: Why the converted SQL could not be run on
            Oracle and/or PostgreSQL. Required when run_ora_sql or
            run_postgres_sql has not run successfully in this chat session
            within the last 30 minutes; otherwise nothing is written and
            ``test_errors`` is returned.

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
        per_file_replacements = _loaded_repl

    project_root = os.path.abspath(project_root) if project_root else os.getcwd()
    per_file_replacements = _normalize_replacements(per_file_replacements, project_root)

    executed = _executed_recently()
    not_run = [db for db in ('oracle', 'postgres') if db not in executed]
    if not_run and not test_skipped_reason.strip():
        return {
            'error': (
                '変換後のSQLを実行した記録がないため、何も書き出していません。'
                'run_ora_sql と run_postgres_sql の両方で変換前後のSQLを実行して結果を比べてから、'
                'もう一度呼んでください。どうしても実行できない場合は、その理由を '
                'test_skipped_reason に書いて呼び、ユーザーにも伝えてください。'
            ),
            'test_errors': [f'{db}: このセッションの直近30分に、成功した実行の記録がありません' for db in not_run],
        }

    overlap = _overlap_errors(per_file_replacements)
    if overlap:
        return {
            'error': '同じファイルの中で行の範囲が重なる置き換えがあるため、何も書き出していません。',
            'overlap_errors': overlap,
        }

    bind_errors, dollar_to_hash = _check_placeholders(per_file_replacements)
    if bind_errors:
        return {
            'error': (
                'バインド変数（プレースホルダ）が変わる置き換えがあるため、何も書き出していません。'
                'original_lines は、指定した行の範囲の今の内容です。置き換えたい行と違う場合は、'
                '行番号（元のファイルの行番号）を直してください。行番号が正しい場合は、プレースホルダの'
                '書き方と名前を元のままにして置き換え直すか、その置き換えを外して manual_review_bind として'
                '報告してから、もう一度呼んでください（${x} を同じ名前の #{x} にするのは、そのまま受け付けます）。'
            ),
            'bind_errors': bind_errors,
        }

    syntax_errors, syntax_checked = _check_host_syntax(per_file_replacements)
    if syntax_errors:
        return {
            'error': (
                '置き換えた行に、元のファイルにはなかった構文エラー（Java、XML などのホスト言語の構文）が'
                'あるため、何も書き出していません。引用符、文字列の連結（+ や .append()）、括弧、XML のタグと'
                'エスケープ（&lt; など）を元の形に合わせて置き換え直してから、もう一度呼んでください。'
            ),
            'syntax_errors': syntax_errors,
        }

    file_mode = (mode or _FILE_MODE) == _FILE_MODE
    results = _normalize_results(per_file_results or {}, project_root) if file_mode else {}
    if file_mode:
        result_errors = _check_results(per_file_replacements, results)
        if result_errors:
            return {
                'error': (
                    'ファイルごとのテストの記録と OK.txt / NG.txt の内容（per_file_results）が足りないため、'
                    '何も書き出していません。置き換えるファイルごとに、status、summary（tool-output-layout の'
                    '雛形のとおり）、oracle_test_sql、oracle_test_result、postgres_test_sql、postgres_test_result、'
                    'comparison_result を渡して、もう一度呼んでください。'
                ),
                'result_errors': result_errors,
            }

    out_dir = os.path.abspath(out_dir)
    os.makedirs(out_dir, exist_ok=True)
    patch_mode = source_patcher.PatchMode.DIFF if file_mode else _coerce_mode(mode)

    # diff / patch leave the source untouched, so replacements from earlier
    # calls are kept and merged: a conversion may be written in several calls.
    dropped = []
    if patch_mode != source_patcher.PatchMode.INPLACE:
        state, dropped = _load_state(out_dir)
        for fp, reps in per_file_replacements.items():
            state[fp] = _merge(state.get(fp, []), reps)
        to_write = {fp: state[fp] for fp in (state if patch_mode == source_patcher.PatchMode.PATCH else per_file_replacements)}
    else:
        state = None
        to_write = per_file_replacements

    patch_path = None
    if patch_mode == source_patcher.PatchMode.PATCH:
        patch_path = os.path.join(out_dir, _PATCH_NAME)
        # Rewritten from all stored replacements on every call.
        open(patch_path, 'w').close()

    diffs_dir = None
    if patch_mode == source_patcher.PatchMode.DIFF:
        diffs_dir = os.path.join(out_dir, _DIFFS_DIRNAME)
    converted_paths = []

    files_patched = 0
    diff_paths = []
    files_not_found = []
    files_unchanged = []
    remaining = []
    for filepath, replacements in to_write.items():
        if not os.path.isfile(filepath):
            files_not_found.append(filepath)
            continue
        result = source_patcher.apply_to_file(
            filepath, replacements, mode=patch_mode,
            project_root=project_root, patch_file=patch_path,
        )
        if not result.changed:
            files_unchanged.append(filepath)
            continue
        files_patched += 1
        with open(filepath, encoding='utf-8') as f:
            converted_lines = (f.readlines() if patch_mode == source_patcher.PatchMode.INPLACE
                               else source_patcher.patch_lines(f.readlines(), replacements))
        remaining.extend(_remaining_oracle(filepath, converted_lines))
        if file_mode:
            rel = os.path.relpath(filepath, project_root)
            conv_path = os.path.join(out_dir, _CONVERTED_DIRNAME, rel)
            os.makedirs(os.path.dirname(conv_path), exist_ok=True)
            Path(conv_path).write_text(''.join(converted_lines), encoding='utf-8')
            converted_paths.append(conv_path)
        if patch_mode == source_patcher.PatchMode.DIFF and result.diff:
            rel = os.path.relpath(filepath, project_root)
            diff_path = os.path.join(out_dir, _DIFFS_DIRNAME, rel + '.diff')
            os.makedirs(os.path.dirname(diff_path), exist_ok=True)
            Path(diff_path).write_text(result.diff, encoding='utf-8')
            diff_paths.append(diff_path)

    if state is not None:
        _save_state(out_dir, state)

    summary_path = None
    if file_mode:
        summary_path = _write_directory_results(out_dir, project_root, results)

    dist = dict(Counter(it.get('review_status', 'not processed')
                        for it in output_items))

    return {
        'patch_path': patch_path,
        'diffs_dir': diffs_dir,
        'converted_paths': converted_paths,
        'summary_path': summary_path,
        'remaining_oracle_syntax': remaining,
        'host_syntax_check': syntax_checked,
        'stale_replacements_dropped': dropped,
        'tests_not_run': not_run,
        'dollar_to_hash': dollar_to_hash,
        'test_skipped_reason': test_skipped_reason,
        'diff_paths': diff_paths,
        'files_patched': files_patched,
        'files_not_found': files_not_found,
        'files_unchanged': files_unchanged,
        'review_status_distribution': dist,
    }


def _normalize_results(per_file_results: dict, project_root: str) -> dict:
    out = {}
    for fp, res in per_file_results.items():
        path = fp if os.path.isabs(fp) or not project_root else os.path.join(project_root, fp)
        out[os.path.abspath(path)] = res if isinstance(res, dict) else {}
    return out


def _check_results(per_file_replacements: dict, results: dict) -> list[dict]:
    """Every replaced file needs a result entry with a status and a summary
    that follows the OK.txt / NG.txt template."""
    errors = []
    for fp in per_file_replacements:
        if fp not in results:
            errors.append({'file': fp, 'issue': 'per_file_results にこのファイルがありません'})
    for fp, res in results.items():
        status = (res.get('status') or '').strip()
        summary = res.get('summary') or ''
        if not status:
            errors.append({'file': fp, 'issue': 'status がありません（tool-review-status の判定区分）'})
            continue
        if not summary.strip():
            errors.append({'file': fp, 'issue': 'summary がありません'})
            continue
        missing = _missing_items(summary, status in _OK_STATUSES)
        if missing:
            errors.append({'file': fp, 'issue': 'summary に必要な見出しまたは項目がありません',
                           'missing_headings': missing})
    return errors


# Order used to pick the status of the whole directory (worst first).
_STATUS_ORDER = ['fail', 'manual_review_bind', 'manual_review_range', 'partial_by_llm',
                 'validator_limitation', 'orm_delegated', 'pass', 'sct_already_handled',
                 'no_change_needed']
_COUNT_RE = re.compile(r'^\s*-\s*(実行したテストケース数|成功/失敗の内訳)\s*[:：]\s*(.*)$', re.M)


def _locked(out_dir: str):
    """Exclusive lock on <out_dir>/.scaw-lock (parallel sub-agents may write
    the same directory)."""
    import fcntl
    f = open(os.path.join(out_dir, _LOCK_NAME), 'w')
    fcntl.flock(f, fcntl.LOCK_EX)
    return f


def _write_directory_results(out_dir: str, project_root: str, results: dict) -> str:
    """Merge this call's per-file results into <out_dir>/.scaw-results.json
    and rebuild the directory-level test files and OK.txt / NG.txt."""
    lock = _locked(out_dir)
    try:
        state_path = os.path.join(out_dir, _RESULTS_STATE)
        try:
            with open(state_path, encoding='utf-8') as f:
                stored = json.load(f)
        except (OSError, ValueError):
            stored = {}
        for fp, res in results.items():
            stored[os.path.relpath(fp, project_root)] = res
        with open(state_path, 'w', encoding='utf-8') as f:
            json.dump(stored, f, ensure_ascii=False, indent=1)

        files = sorted(stored)
        tests = {}
        for key, name in _TEST_KEYS:
            comment = '--' if name.endswith('.sql') else ''
            parts = []
            for rel in files:
                text = (stored[rel].get(key) or '').strip() or '(テストは実行していません)'
                parts.append(f'{comment}{"" if not comment else " "}===== {rel} =====\n{text}\n')
            tests[key] = '\n'.join(parts)
        write_test_files(out_dir, tests)

        statuses = {rel: (stored[rel].get('status') or '').strip() for rel in files}
        worst = min(statuses.values(), key=lambda st: _STATUS_ORDER.index(st)
                    if st in _STATUS_ORDER else -1)
        is_ok = all(st in _OK_STATUSES for st in statuses.values())
        n_ok = sum(st in _OK_STATUSES for st in statuses.values())
        lines = [
            '## 基本情報',
            f'- ステータス: {worst}（OK {n_ok}ファイル / NG {len(files) - n_ok}ファイル）',
            f'- 変換対象: {project_root}（{len(files)}ファイル）',
            '- 実施日時: <filled>',
            '',
            '## ファイルごとの結果',
            '| ファイル | 判定 | 実行したテストケース数 | 成功/失敗の内訳 |',
            '|---|---|---|---|',
        ]
        for rel in files:
            counts = dict(_COUNT_RE.findall(stored[rel].get('summary') or ''))
            lines.append(f'| {rel} | {statuses[rel]} | {counts.get("実行したテストケース数", "")}'
                         f' | {counts.get("成功/失敗の内訳", "")} |')
        for rel in files:
            body = re.sub(r'^## ', '### ', (stored[rel].get('summary') or '').strip(), flags=re.M)
            lines += ['', f'## {rel}', body]
        return write_summary(out_dir, is_ok, _fill_timestamp('\n'.join(lines) + '\n'))
    finally:
        lock.close()


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
