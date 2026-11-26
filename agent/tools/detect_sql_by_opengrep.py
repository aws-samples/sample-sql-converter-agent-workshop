"""`detect_sql_by_opengrep` MCP tool.

Runs opengrep against a single file using a caller-provided rules YAML and
returns the parsed JSON results. Thin wrapper around the `opengrep` CLI —
the actual rules (taint / pattern) live in the rules YAML, not this module.

Helpers ``_find_sql_keyword_line`` and ``_find_end_by_semicolon``
deterministically shift opengrep's hit line to the actual SQL body line
and find the statement end, so source_patcher can apply edits correctly.

Requires the ``opengrep`` binary to be on PATH.
"""

import json
import os
import re
import shutil
import subprocess
import tempfile

from logging_setup import correlation_id, get_logger

#: Per-file CLI timeout (seconds).
OPENGREP_TIMEOUT_SECONDS = 60
#: Lines scanned forward from a SQL start to find the statement end.
OPENGREP_MAX_SCAN_LINES = 30
#: Batch scan: base timeout + per-file timeout (seconds), files per spawn.
OPENGREP_BATCH_BASE_TIMEOUT = 120
OPENGREP_BATCH_PER_FILE_TIMEOUT = 2
OPENGREP_BATCH_CHUNK_SIZE = 200


_logger = get_logger('tools.detect_sql_by_opengrep')


from dataclasses import dataclass, field


@dataclass
class _ScanState:
    """Mutable state shared by the taint and pattern passes.

    Bundles the three structures the passes previously mutated as
    separate positional args, making the pass API explicit about the
    coupling (pattern pass reads taint_sources / taint_coverage that
    the taint pass wrote).
    """
    #: SQL start line -> end line (final hit ranges).
    all_ranges: dict = field(default_factory=dict)
    #: Start lines confirmed as Dynamic SQL taint sources.
    taint_sources: set = field(default_factory=set)
    #: Taint source line -> sink line (raw coverage, pre-shrink).
    taint_coverage: dict = field(default_factory=dict)


_SQL_KEYWORD_RE = re.compile(r'\b(SELECT|INSERT|UPDATE|DELETE|MERGE|WITH)\b', re.IGNORECASE)
_COMMENT_RE = re.compile(r'^\s*(//|#|--|\*|/\*)')


def _find_sql_keyword_line(lines: list[str], start_line: int) -> int:
    """Return the nearest line to ``start_line`` that actually contains a SQL
    keyword outside of a comment. Searches 0, -1, -2, -3, then +1, +2, +3.

    Skips lines where the SQL keyword sits inside a Python triple-quote
    closing expression (e.g. a line starting with triple-quote followed
    by a dict literal containing a keyword). Without this, the resolver
    latches onto the previous block terminator when scanning near a new
    triple-quoted SQL block.

    ``start_line`` is 1-based. Returns 1-based line number.
    """
    for offset in [0] + list(range(-1, -4, -1)) + list(range(1, 4)):
        idx = start_line + offset
        if 1 <= idx <= len(lines):
            text = lines[idx - 1]
            if _COMMENT_RE.match(text):
                continue
            m = _SQL_KEYWORD_RE.search(text)
            if not m:
                continue
            # A Python triple-quote closing line looks like `""", ...` or
            # `"""` at column 0/near. If the line starts with `"""` OR
            # `'''`, any SQL keyword further in the line is inside a
            # dict/tuple literal — not SQL. Skip it so the resolver can
            # move on to the next candidate line.
            if text.lstrip().startswith(('"""', "'''")):
                continue
            return idx
    return start_line


def _find_end_by_semicolon(lines: list[str], start_line: int, max_scan: int = OPENGREP_MAX_SCAN_LINES) -> int:
    """Find the end line of a SQL statement starting at ``start_line`` by
    walking forward until a semicolon, closing string continuation, or the
    end of a StringBuilder.append chain.

    Handles:
    - Java ``+`` concatenation, C adjacent string literals
    - Ruby / Python / PHP / C backslash continuations
    - Python triple-quoted strings
    - StringBuilder.append / .Append / += chains (extends scan window)

    ``start_line`` is 1-based. Returns 1-based end line.
    """
    i = start_line - 1
    in_triple = False
    limit = min(start_line + max_scan, len(lines))
    while i < limit:
        stripped = lines[i].rstrip()

        triple_count = stripped.count('"""') + stripped.count("'''")
        if triple_count % 2 == 1:
            in_triple = not in_triple
            if not in_triple:
                return i + 1
            i += 1
            continue
        if in_triple:
            i += 1
            continue

        if stripped.endswith('\\'):
            i += 1
            continue

        if (stripped.endswith('"') or stripped.endswith("'")) \
                and not stripped.endswith('"""') and not stripped.endswith("'''"):
            if i + 1 < len(lines):
                next_stripped = lines[i + 1].strip()
                # Continuation cases:
                #   - C / C# adjacent literals: next line starts with quote.
                #   - Java / JS / VB concat: next line starts with `+`, `&`,
                #     `||`, `.` before the quoted literal.
                if next_stripped.startswith(('"', "'")):
                    i += 1
                    continue
                if next_stripped.startswith(('+', '&', '||', '.')):
                    i += 1
                    continue
            return i + 1

        if stripped.endswith(';'):
            if '.append(' in stripped or '.Append(' in stripped or '+=' in stripped:
                if i + 1 < len(lines):
                    next_s = lines[i + 1].strip()
                    if '.append(' in next_s or '.Append(' in next_s or '+=' in next_s:
                        limit = min(i + max_scan + 2, len(lines))
                        i += 1
                        continue
            return i + 1

        i += 1

    # Fallback: scan from start for any semicolon
    for i in range(start_line - 1, min(start_line + max_scan, len(lines))):
        if lines[i].rstrip().endswith(';'):
            return i + 1
    return start_line


_DEFAULT_TAINT_RULES = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), 'rules', 'opengrep_taint_rules.yaml',
)
_DEFAULT_PATTERN_RULES = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), 'rules', 'opengrep_pattern_rules.yaml',
)


# ---------------------------------------------------------------------------
# Binary resolution / version logging
# ---------------------------------------------------------------------------

#: Well-known install locations probed when `opengrep` is not on PATH.
#: The official install.sh links ~/.local/bin/opengrep ->
#: ~/.opengrep/cli/latest/opengrep, but non-login shells (IDEs, CI
#: steps, MCP server processes) frequently lack ~/.local/bin on PATH.
_FALLBACK_BIN_PATHS = (
    os.path.expanduser('~/.local/bin/opengrep'),
    os.path.expanduser('~/.opengrep/cli/latest/opengrep'),
)

_bin_cache: str | None = None
_bin_resolved = False
_version_logged = False


def _resolve_opengrep_bin() -> str | None:
    """Locate the opengrep binary.

    Order: ``OPMS_OPENGREP_BIN`` env var → PATH → well-known install
    locations. Result is cached for the process lifetime; returns
    ``None`` when nothing is found.
    """
    global _bin_cache, _bin_resolved
    if _bin_resolved:
        return _bin_cache
    env_bin = os.environ.get('OPMS_OPENGREP_BIN', '')
    if env_bin:
        if os.path.isfile(env_bin) and os.access(env_bin, os.X_OK):
            _bin_cache = env_bin
        else:
            _logger.warning(
                'OPMS_OPENGREP_BIN is set but not an executable file; '
                'falling back to PATH probing',
                extra={'value': env_bin},
            )
    if _bin_cache is None:
        _bin_cache = shutil.which('opengrep')
    if _bin_cache is None:
        for cand in _FALLBACK_BIN_PATHS:
            if os.path.isfile(cand) and os.access(cand, os.X_OK):
                _bin_cache = cand
                _logger.info(
                    'opengrep resolved via fallback location '
                    '(not on PATH)', extra={'path': cand},
                )
                break
    _bin_resolved = True
    _log_version_once()
    return _bin_cache


def _log_version_once() -> None:
    """Log the opengrep version once per process (diagnostics aid)."""
    global _version_logged
    if _version_logged or not _bin_cache:
        return
    _version_logged = True
    try:
        proc = subprocess.run(
            [_bin_cache, '--version'], capture_output=True, text=True,
            timeout=30, check=False,
        )
        version = (proc.stdout or '').strip().splitlines()[0] if proc.stdout else ''
        _logger.info('opengrep version',
                     extra={'bin': _bin_cache, 'version': version})
    except (subprocess.TimeoutExpired, OSError) as exc:
        _logger.warning('opengrep --version failed',
                        extra={'bin': _bin_cache, 'error': str(exc)})


def _taint_pass(filepath: str, taint_rules: str, timeout: int,
                lines: list[str], state: '_ScanState',
                raw: dict | None = None) -> bool:
    """Phase 1 — taint analysis for Dynamic SQL (source→sink ranges).

    Mutates *state* in place. ``raw`` short-circuits the opengrep
    invocation with pre-fetched results (batch scan path). Returns
    False when the scan FAILED (as opposed to scanning clean).
    """
    all_ranges = state.all_ranges
    taint_sources = state.taint_sources
    taint_coverage = state.taint_coverage
    taint_data = raw if raw is not None else _run_opengrep_raw(
        filepath, taint_rules, taint=True, timeout=timeout)
    if taint_data is None:
        return False
    raw_count = len(taint_data.get('results', []))
    parsed_count = 0
    for r in taint_data.get('results', []):
        trace = r.get('extra', {}).get('dataflow_trace')
        if not (trace and trace.get('taint_source')):
            continue
        ts = trace['taint_source']
        if not (isinstance(ts, list) and len(ts) >= 2):
            continue
        loc = ts[1]
        if not (isinstance(loc, list) and len(loc) >= 1 and isinstance(loc[0], dict)):
            continue
        source_line = loc[0].get('start', {}).get('line')
        sink_line = r['start']['line']
        if not source_line:
            continue
        parsed_count += 1
        orig_source_line = source_line
        source_line = _find_sql_keyword_line(lines, source_line)

        # VB.NET fix-up: if the line *before* source_line ends with `_`
        # (line continuation) or contains `String.Format(`, the SQL actually
        # starts on that previous line (start_line points at the
        # `String.Format(` line).
        if source_line >= 2:
            prev = lines[source_line - 2].rstrip()
            if prev.endswith('_') or 'String.Format(' in prev:
                source_line -= 1

        taint_coverage[source_line] = max(taint_coverage.get(source_line, 0), sink_line)

        range_start = min(source_line, orig_source_line)
        if range_start >= 2:
            prev = lines[range_start - 2].strip()
            if prev.endswith('_') or 'String.Format(' in prev:
                range_start -= 1
        range_text = ''.join(lines[range_start - 1:sink_line])
        has_dynamic = any(kw in range_text for kw in _DYNAMIC_KEYWORDS)
        if not has_dynamic:
            has_dynamic = bool(re.search(r'\bsql\w*\s*=\s*[a-zA-Z_]\w*\(', range_text, re.IGNORECASE))
        if has_dynamic:
            taint_sources.add(source_line)
            all_ranges[source_line] = max(all_ranges.get(source_line, 0), sink_line)

    # Shrink taint_coverage when it contains another taint source
    sorted_cov = sorted(taint_coverage.keys())
    for i, s in enumerate(sorted_cov):
        e = taint_coverage[s]
        for s2 in sorted_cov[i + 1:]:
            if s2 > e:
                break
            if s2 > s:
                taint_coverage[s] = s2 - 1
                break
    # Format-drift telemetry: opengrep returned taint results but NONE
    # yielded a parseable dataflow trace. The trace shape
    # (taint_source[1][0].start.line) is an undocumented opengrep
    # internal — a version upgrade changing it would otherwise silently
    # zero out all Dynamic SQL detection.
    if raw_count > 0 and parsed_count == 0:
        _logger.warning(
            'taint results present but no dataflow_trace parsed — '
            'possible opengrep output-format change',
            extra={'filepath': filepath, 'raw_results': raw_count},
        )
    return True


def _pattern_pass(filepath: str, pattern_rules: str, timeout: int,
                  lines: list[str], state: '_ScanState',
                  raw: dict | None = None) -> bool:
    """Phase 2 — pattern matching (JPA annotations, then other rules).

    JPA hits take precedence over taint; pattern hits inside an
    active taint range are excluded to avoid double-counting.
    Mutates *state* in place. ``raw`` short-circuits the opengrep
    invocation (batch scan path). Returns False when the scan FAILED.
    """
    all_ranges = state.all_ranges
    taint_sources = state.taint_sources
    taint_coverage = state.taint_coverage
    pattern_data = raw if raw is not None else _run_opengrep_raw(
        filepath, pattern_rules, taint=False, timeout=timeout)
    if pattern_data is None:
        return False
    jpa_lines: set[int] = set()
    for r in pattern_data.get('results', []):
        check_id = r.get('check_id', '')
        if not any(k in check_id for k in ('named-query', 'named-native-query', 'spring-query')):
            continue
        # Pull start/end from the $SQL metavar so each @NamedQuery hits
        # individually (rather than as part of the @NamedQueries wrapper).
        sql_meta = r.get('extra', {}).get('metavars', {}).get('$SQL', {})
        line = sql_meta.get('start', {}).get('line', r['start']['line'])
        end_line = sql_meta.get('end', {}).get('line', line)
        jpa_lines.add(line)
        if line not in all_ranges or line in taint_sources:
            all_ranges[line] = end_line

    # JPA hits take precedence over taint
    for ts in list(taint_sources):
        if ts in jpa_lines:
            taint_sources.discard(ts)

    # Other pattern rules
    for r in pattern_data.get('results', []):
        check_id = r.get('check_id', '')
        if any(k in check_id for k in ('named-query', 'named-native-query', 'spring-query')):
            continue
        if 'exec-triple' in check_id:
            line = _find_sql_keyword_line(lines, r['start']['line'])
            end_line = r['end']['line']
            all_ranges.setdefault(line, end_line)
            continue
        line = _find_sql_keyword_line(lines, r['start']['line'])
        pattern_end = r.get('end', {}).get('line', line)
        end_line = max(_find_end_by_semicolon(lines, line), pattern_end)
        if line in taint_sources or line in all_ranges:
            continue
        in_taint = any(ts <= line <= te for ts, te in all_ranges.items())
        if not in_taint:
            in_taint = any(ts <= line <= te for ts, te in taint_coverage.items() if ts != line)
        if in_taint:
            src = lines[line - 1] if line <= len(lines) else ''
            prev = lines[line - 2].rstrip() if line >= 2 else ''
            if '.append(' in src or '.concat(' in src or '+=' in src or prev.endswith('+'):
                continue
            if prev.endswith('"') and not prev.endswith('"""') and not prev.endswith("'''"):
                continue
            if prev.rstrip().endswith('& _') or '&= ' in src or prev.rstrip().endswith('_'):
                continue
        all_ranges[line] = end_line
    return True


def _detect_hits_structured(
    filepath: str, pattern_rules: str, taint_rules: str, timeout: int,
    raw_taint: dict | None = None, raw_pattern: dict | None = None,
) -> tuple[list[dict], list[str]]:
    """Run taint + pattern opengrep passes and merge results into per-SQL hits.

    Handles:
      * Taint analysis for Dynamic SQL (source→sink range) with dedup
      * Pattern matching for Static SQL + JPA @Query / @NamedQuery metavar
        separation (each @NamedQuery becomes its own hit, not merged into
        the enclosing @NamedQueries block)
      * Exclusion of pattern hits that fall inside an active taint range
        (avoids double-counting one SQL)
      * Taint range shrinkage when it contains another SQL start
    """
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()
    except OSError as exc:
        return [], [f'cannot read {filepath}: {exc}']

    state = _ScanState()
    scan_errors: list[str] = []

    if not _taint_pass(filepath, taint_rules, timeout, lines, state,
                       raw=raw_taint):
        scan_errors.append('taint scan failed (see logs)')

    if not _pattern_pass(filepath, pattern_rules, timeout, lines, state,
                         raw=raw_pattern):
        scan_errors.append('pattern scan failed (see logs)')

    all_ranges = state.all_ranges
    taint_sources = state.taint_sources

    # Shrink taint ranges so they don't overlap with other SQL starts
    sorted_starts = sorted(all_ranges.keys())
    for i, s in enumerate(sorted_starts):
        e = all_ranges[s]
        if s in taint_sources:
            for s2 in sorted_starts[i + 1:]:
                if s2 > e:
                    break
                if s2 > s:
                    all_ranges[s] = s2 - 1
                    break

    hits = [
        {'start_line': sl, 'end_line': all_ranges[sl], 'rule_id': '', 'message': '',
         'dynamic': sl in taint_sources}
        for sl in sorted(all_ranges)
    ]
    return hits, scan_errors


_DYNAMIC_KEYWORDS = (
    '.append(', '.Append(', '.concat(', '+=', ' if ', ' if(', 'elif ',
    'else:', 'else{', ' for ', ' for(', 'foreach', ' while ', ' while(',
    'switch ', 'sprintf(', 'strcat(', 'f"""', "f'''", '${',
    'String.Format(', '&= ',
)
# Note: `" +` / `+ "` / `' +` / `+ '` are DELIBERATELY excluded — a pure
# compile-time string concatenation like `"SELECT ..." + "FROM ..."` is
# Static SQL, not Dynamic. Dynamic concat shows up via `+=`, `.append(`,
# or a branch keyword ( if/for/while ) already listed above.


def _run_opengrep_raw(filepath: str, rules_yaml: str, taint: bool,
                      timeout: int) -> dict | None:
    """Low-level opengrep invocation returning raw JSON. cwd-isolated.

    Returns ``None`` on FAILURE (binary missing, timeout after one
    retry, unparseable output, OS error) so callers can distinguish
    "scan failed" from "scanned clean" (``{'results': []}``). Silent
    conflation of the two previously made a timed-out file look like
    it contained no SQL at all.
    """
    bin_path = _resolve_opengrep_bin()
    if not bin_path:
        _logger.warning('opengrep binary not found (PATH, '
                        'OPMS_OPENGREP_BIN, fallback locations)')
        return None
    if not os.path.isfile(filepath):
        _logger.warning('opengrep target file missing',
                        extra={'filepath': filepath})
        return None
    if not os.path.isfile(rules_yaml):
        _logger.warning('opengrep rules YAML missing',
                        extra={'rules_yaml': rules_yaml})
        return None
    cmd = [
        bin_path,
        '--config', os.path.abspath(rules_yaml),
        os.path.abspath(filepath),
        '--json', '--no-git-ignore',
    ]
    if taint:
        cmd.extend(['--dataflow-traces', '--taint-intrafile'])
    return _exec_opengrep(cmd, timeout)


def _exec_opengrep(cmd: list[str], timeout: int) -> dict | None:
    """Execute an opengrep command with one retry on timeout.

    Returns parsed JSON dict, or ``None`` on failure. opengrep's own
    per-rule ``errors[]`` array is logged (WARNING) but does not fail
    the call — partial results are still useful.
    """
    for attempt in (1, 2):
        try:
            with tempfile.TemporaryDirectory(prefix='opengrep-') as tmpd:
                open(os.path.join(tmpd, '.semgrepignore'), 'w').close()
                proc = subprocess.run(
                    cmd, capture_output=True, text=True, timeout=timeout,
                    check=False, cwd=tmpd,
                )
            break
        except subprocess.TimeoutExpired:
            _logger.warning(
                'opengrep timed out',
                extra={'timeout': timeout, 'attempt': attempt,
                       'cmd_tail': cmd[-3:]},
            )
            if attempt == 2:
                return None
        except OSError as exc:
            _logger.warning('opengrep spawn failed',
                            extra={'error': str(exc)})
            return None
    try:
        data = json.loads(proc.stdout or '{}')
    except json.JSONDecodeError as exc:
        _logger.warning(
            'opengrep produced unparseable JSON',
            extra={'error': str(exc), 'returncode': proc.returncode,
                   'stderr_tail': (proc.stderr or '')[-500:]},
        )
        return None
    for err in data.get('errors', []):
        _logger.warning(
            'opengrep reported error',
            extra={'opengrep_error': str(err)[:500]},
        )
    return data


def detect_sql_by_opengrep(
    filepath: str,
    rules_yaml: str = '',
    taint: bool = False,
    timeout: int = OPENGREP_TIMEOUT_SECONDS,
    raw_taint: dict | None = None,
    raw_pattern: dict | None = None,
) -> dict:
    """Run opengrep on a single file and return structured SQL hits.

    Internally runs BOTH taint and pattern passes against the bundled
    rule bundles (when ``rules_yaml`` is empty) and merges results via
    the taint/pattern coordination logic. Each hit gets
    corrected start_line / end_line via the deterministic post-processor.

    Args:
        filepath: Absolute or relative path to the source file to scan.
        rules_yaml: If set, uses this rules file for the single-rule
            mode (taint-only when ``taint=True``, else pattern-only).
            If empty, runs both bundled rule sets and merges them.
        taint: Only honored when ``rules_yaml`` is explicitly provided.
            Passing ``taint=True`` without ``rules_yaml`` logs a
            warning and is otherwise ignored (the default path always
            runs both passes).
        timeout: CLI timeout in seconds (default
            ``OPENGREP_TIMEOUT_SECONDS``).
        raw_taint: Pre-fetched taint-pass opengrep JSON for this file
            (from ``scan_files_opengrep``). Skips the per-file spawn.
        raw_pattern: Pre-fetched pattern-pass opengrep JSON. Both raw
            params must be provided together for a fully spawn-free run.

    Returns:
        dict with ``ok``, ``hits`` (list of {start_line, end_line,
        rule_id, message}), ``count``, ``errors``.
    """
    with correlation_id() as cid:
        _logger.info(
            'detect_sql_by_opengrep start',
            extra={'filepath': filepath, 'rules': rules_yaml or '(default bundles)',
                   'taint': taint},
        )
        if taint and not rules_yaml:
            _logger.warning(
                'detect_sql_by_opengrep: taint=True is ignored without '
                'rules_yaml (default path always runs both passes)',
                extra={'correlation_id': cid},
            )

        if not _resolve_opengrep_bin() and raw_taint is None:
            return _fail(
                'opengrep binary not found (checked OPMS_OPENGREP_BIN, '
                'PATH, ~/.local/bin, ~/.opengrep/cli/latest)', cid)
        if not os.path.isfile(filepath):
            return _fail(f'file not found: {filepath}', cid)

        # Default path: combined taint + pattern detection
        if not rules_yaml:
            if not os.path.isfile(_DEFAULT_TAINT_RULES) or not os.path.isfile(_DEFAULT_PATTERN_RULES):
                return _fail('bundled rules missing', cid)
            hits, scan_errors = _detect_hits_structured(
                filepath, _DEFAULT_PATTERN_RULES, _DEFAULT_TAINT_RULES,
                timeout, raw_taint=raw_taint, raw_pattern=raw_pattern,
            )
            _logger.info(
                'detect_sql_by_opengrep done',
                extra={'hit_count': len(hits), 'scan_errors': len(scan_errors),
                       'correlation_id': cid},
            )
            # ok=False only when BOTH passes failed — a partial scan
            # still carries usable hits, but the errors list tells the
            # caller the coverage was incomplete.
            both_failed = len(scan_errors) >= 2
            return {'ok': not both_failed, 'hits': hits,
                    'count': len(hits),
                    'errors': [{'message': e} for e in scan_errors]}

        # Single-rule path (explicit rules_yaml)
        if not os.path.isfile(rules_yaml):
            return _fail(f'rules YAML not found: {rules_yaml}', cid)
        raw = _run_opengrep_raw(filepath, rules_yaml, taint, timeout)
        if raw is None:
            return _fail('opengrep invocation failed (see logs)', cid)
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                file_lines = f.readlines()
        except OSError:
            file_lines = []
        hits = []
        for m in raw.get('results', []):
            start = m.get('start', {}).get('line')
            end = m.get('end', {}).get('line') or start
            if not start or not file_lines:
                continue
            corrected_start = _find_sql_keyword_line(file_lines, start)
            corrected_end = max(end, _find_end_by_semicolon(file_lines, corrected_start))
            hits.append({
                'start_line': corrected_start,
                'end_line': corrected_end,
                'rule_id': m.get('check_id', ''),
                'message': m.get('extra', {}).get('message', ''),
            })
        _logger.info(
            'detect_sql_by_opengrep done',
            extra={'hit_count': len(hits), 'correlation_id': cid},
        )
        return {
            'ok': True, 'hits': hits, 'count': len(hits),
            'errors': raw.get('errors', []),
        }


def _fail(msg: str, cid: str, stderr: str = '') -> dict:
    _logger.warning(
        'detect_sql_by_opengrep failed',
        extra={'error': msg, 'correlation_id': cid},
    )
    return {
        'ok': False,
        'hits': [],
        'matches': [],
        'count': 0,
        'errors': [{'message': msg}],
        'stderr': (stderr or '')[:2048],
    }


# ---------------------------------------------------------------------------
# Project-level batch scan (one spawn for many files)
# ---------------------------------------------------------------------------

def _rule_ids_from_yaml(yaml_path: str) -> set[str]:
    """Extract rule ids from a rules YAML (cheap regex, no YAML dep)."""
    try:
        with open(yaml_path, encoding='utf-8') as f:
            return set(re.findall(r'^\s*-\s*id:\s*(\S+)', f.read(), re.M))
    except OSError:
        return set()


def scan_files_opengrep(
    files: list[str],
    timeout: int | None = None,
    chunk_size: int = OPENGREP_BATCH_CHUNK_SIZE,
) -> dict:
    """Scan many files with ONE opengrep invocation per chunk.

    Runs both bundled rule sets (pattern + taint, `--dataflow-traces
    --taint-intrafile`) in a single spawn and splits the results per
    file and per rule kind. Compared to the per-file path (2 spawns ×
    N files at ~1.2 s Nuitka startup each), a 500-file project drops
    from ~1000 spawns to ~3.

    Args:
        files: File paths to scan (source-kind files).
        timeout: Per-chunk timeout. Defaults to
            ``OPENGREP_BATCH_BASE_TIMEOUT +
            OPENGREP_BATCH_PER_FILE_TIMEOUT × len(chunk)``.
        chunk_size: Max files per invocation (bounds argv length and
            hang blast-radius).

    Returns:
        ``{'per_file': {abspath: {'taint': {'results': [...]},
        'pattern': {'results': [...]}}}, 'errors': [str, ...],
        'ok': bool}``. ``ok`` is False when every chunk failed.
        Files with no hits still get empty result dicts, so callers
        can distinguish "scanned clean" from "not scanned".
    """
    bin_path = _resolve_opengrep_bin()
    result: dict = {'per_file': {}, 'errors': [], 'ok': True}
    if not files:
        return result
    if not bin_path:
        result['ok'] = False
        result['errors'].append(
            'opengrep binary not found (checked OPMS_OPENGREP_BIN, '
            'PATH, ~/.local/bin, ~/.opengrep/cli/latest)')
        return result
    if (not os.path.isfile(_DEFAULT_TAINT_RULES)
            or not os.path.isfile(_DEFAULT_PATTERN_RULES)):
        result['ok'] = False
        result['errors'].append('bundled rules missing')
        return result

    taint_ids = _rule_ids_from_yaml(_DEFAULT_TAINT_RULES)
    abspaths = [os.path.abspath(f) for f in files if os.path.isfile(f)]
    if not abspaths:
        return result
    # Pre-seed every requested file so "scanned clean" is explicit.
    for ap in abspaths:
        result['per_file'][ap] = {'taint': {'results': []},
                                  'pattern': {'results': []}}

    failed_chunks = 0
    total_chunks = 0
    for i in range(0, len(abspaths), chunk_size):
        chunk = abspaths[i:i + chunk_size]
        total_chunks += 1
        chunk_timeout = timeout or (
            OPENGREP_BATCH_BASE_TIMEOUT
            + OPENGREP_BATCH_PER_FILE_TIMEOUT * len(chunk))
        cmd = [
            bin_path,
            '--config', os.path.abspath(_DEFAULT_PATTERN_RULES),
            '--config', os.path.abspath(_DEFAULT_TAINT_RULES),
            *chunk,
            '--json', '--no-git-ignore',
            '--dataflow-traces', '--taint-intrafile',
        ]
        data = _exec_opengrep(cmd, chunk_timeout)
        if data is None:
            failed_chunks += 1
            result['errors'].append(
                f'batch chunk {total_chunks} failed '
                f'({len(chunk)} files; see logs)')
            # Mark chunk files as NOT scanned (remove pre-seeded empties)
            for ap in chunk:
                result['per_file'].pop(ap, None)
            continue
        for r in data.get('results', []):
            path = os.path.abspath(r.get('path', ''))
            slot = result['per_file'].get(path)
            if slot is None:
                continue
            rule_leaf = (r.get('check_id') or '').rsplit('.', 1)[-1]
            kind = 'taint' if rule_leaf in taint_ids else 'pattern'
            slot[kind]['results'].append(r)
        for err in data.get('errors', []):
            result['errors'].append(str(err)[:500])

    if failed_chunks and failed_chunks == total_chunks:
        result['ok'] = False
    _logger.info(
        'scan_files_opengrep done',
        extra={'files': len(files), 'chunks': total_chunks,
               'failed_chunks': failed_chunks,
               'hit_files': sum(
                   1 for v in result['per_file'].values()
                   if v['taint']['results'] or v['pattern']['results'])},
    )
    return result
