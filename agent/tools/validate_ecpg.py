"""`validate_ecpg` MCP tool — precompile-check one EXEC SQL statement.

Wraps a single (converted) ``EXEC SQL`` statement in a minimal ``.pgc``
scaffold — synthesized declare section, dummy cursor declarations — and
runs the PostgreSQL ``ecpg`` precompiler with ``-C ORACLE``.

What ecpg validates (measured against ecpg 18.4):

- EXEC SQL wrapper grammar: INTO clause, indicator variables, CONNECT,
  WHENEVER, cursor statements, PREPARE/EXECUTE.
- Host-variable declaration integrity (undeclared var = error) and
  indicator type (must be integer).
- Oracle-only precompiler grammar is rejected (``COMMIT WORK RELEASE``,
  ``FOR :n`` host arrays, ``EXECUTE ... END-EXEC`` PL/SQL blocks) — the
  exact signals the Pro*C -> ECPG conversion must eliminate.

What it does NOT validate: SQL statement semantics — ``NVL``/``ROWNUM``
pass straight through. Callers must pair this with ``validate_pg_sql``
on the extracted inner SQL.

Binary resolution mirrors the opengrep pattern: ``OPMS_ECPG_BIN`` env
var, then PATH, then common install locations. When no binary is found
the tool degrades gracefully (``ecpg_available=False``, ``clean=True``)
so runs never abort — callers record ``validator_limitation``.
"""

import os
import re
import shutil
import subprocess
import tempfile

from logging_setup import correlation_id, get_logger


_logger = get_logger('tools.validate_ecpg')

_FALLBACK_LOCATIONS = (
    '/opt/homebrew/opt/libpq/bin/ecpg',
    '/opt/homebrew/bin/ecpg',
    '/usr/local/pgsql/bin/ecpg',
    '/usr/bin/ecpg',
)

_bin_resolved = False
_bin_cache: str | None = None
_version_logged = False


def _reset_bin_cache() -> None:
    """Test hook: forget the resolved binary."""
    global _bin_resolved, _bin_cache, _version_logged
    _bin_resolved = False
    _bin_cache = None
    _version_logged = False


def _resolve_ecpg_bin() -> str | None:
    """Locate the ecpg binary: env -> PATH -> known locations."""
    global _bin_resolved, _bin_cache
    if _bin_resolved:
        return _bin_cache
    cand = os.environ.get('OPMS_ECPG_BIN') or shutil.which('ecpg')
    if not cand:
        for loc in _FALLBACK_LOCATIONS:
            if os.path.isfile(loc) and os.access(loc, os.X_OK):
                cand = loc
                break
    if not cand:
        # Homebrew keg-only postgresql@NN / Debian pg-server layouts
        # keep ecpg off PATH.
        import glob
        for pat in ('/opt/homebrew/opt/postgresql*/bin/ecpg',
                    '/usr/lib/postgresql/*/bin/ecpg'):
            hits = sorted(glob.glob(pat))
            if hits:
                cand = hits[-1]
                break
    _bin_resolved = True
    _bin_cache = cand
    _logger.info('validate_ecpg.bin_resolved', extra={'bin': cand or ''})
    return _bin_cache


def _log_version_once(bin_path: str) -> None:
    global _version_logged
    if _version_logged:
        return
    _version_logged = True
    try:
        r = subprocess.run([bin_path, '--version'], capture_output=True,
                           text=True, timeout=10)
        _logger.info('validate_ecpg.version',
                     extra={'version': (r.stdout or '').strip()})
    except (OSError, subprocess.TimeoutExpired):
        pass


# ---------------------------------------------------------------------------
# Host-variable extraction & scaffold synthesis
# ---------------------------------------------------------------------------

_SQ_STRING = re.compile(r"'(?:[^']|'')*'")
_HOSTVAR = re.compile(r'(?<!:):([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)')
_IND_ADJACENT = re.compile(
    r'(?<!:):[A-Za-z_][\w.]*\s*:([A-Za-z_][\w.]*)')
_IND_KEYWORD = re.compile(
    r':[A-Za-z_][\w.]*\s+INDICATOR\s+:([A-Za-z_][\w.]*)', re.IGNORECASE)
_CURSOR_STMT = re.compile(
    r'^\s*(?:EXEC\s+SQL\s+)?(?:OPEN|CLOSE|FETCH)\s+'
    r'(?:(?:NEXT|PRIOR|FIRST|LAST|FORWARD|BACKWARD|ABSOLUTE\s+\S+|'
    r'RELATIVE\s+\S+)\s+)?(?:FROM\s+|IN\s+)?([A-Za-z_]\w*)',
    re.IGNORECASE)
_DECLARES_CURSOR = re.compile(
    r'^\s*(?:EXEC\s+SQL\s+)?DECLARE\s+([A-Za-z_]\w*)\s+CURSOR\b',
    re.IGNORECASE)


def _mask_sql_strings(stmt: str) -> str:
    return _SQ_STRING.sub(lambda m: "'" + ' ' * (len(m.group(0)) - 2) + "'",
                          stmt)


def extract_host_vars(statement: str) -> dict:
    """Extract host-variable references from one EXEC SQL statement.

    Returns dict with:
      ``plain``   — set of scalar var names (value position)
      ``ind``     — set of scalar var names used as indicators
      ``structs`` — {var: set(fields)} for single-level ``:s.f`` refs
      ``ind_structs`` — same, for indicator position
      ``skip_reason`` — non-empty when the statement uses a form the
        scaffold cannot synthesize (nested struct paths).
    """
    masked = _mask_sql_strings(statement)
    ind_names = set(_IND_ADJACENT.findall(masked))
    ind_names |= {m for m in _IND_KEYWORD.findall(masked)}
    plain, structs = set(), {}
    ind, ind_structs = set(), {}
    skip_reason = ''
    for name in _HOSTVAR.findall(masked):
        parts = name.split('.')
        is_ind = name in ind_names
        if len(parts) == 1:
            (ind if is_ind else plain).add(name)
        elif len(parts) == 2:
            target = ind_structs if is_ind else structs
            target.setdefault(parts[0], set()).add(parts[1])
        else:
            skip_reason = f'nested struct host variable :{name}'
    # A name used both as value and indicator must get the integer type.
    plain -= ind
    for var in ind_structs:
        structs.pop(var, None)
    return {'plain': plain, 'ind': ind, 'structs': structs,
            'ind_structs': ind_structs, 'skip_reason': skip_reason}


def build_scaffold(statement: str) -> tuple[str, int, str]:
    """Wrap *statement* in a minimal .pgc program.

    Returns (scaffold_source, statement_line_offset, skip_reason).
    ``statement_line_offset`` = number of scaffold lines before the
    statement's first line (for error line mapping).
    """
    stmt = statement.strip()
    if not re.match(r'^EXEC\s+(SQL|ORACLE)\b', stmt, re.IGNORECASE):
        stmt = 'EXEC SQL ' + stmt
    if not stmt.rstrip().endswith(';'):
        stmt = stmt.rstrip() + ';'

    hv = extract_host_vars(stmt)
    if hv['skip_reason']:
        return '', 0, hv['skip_reason']

    decls = []
    for name in sorted(hv['plain']):
        decls.append(f'char {name}[256];')
    for name in sorted(hv['ind']):
        decls.append(f'short {name};')
    for var, fields in sorted(hv['structs'].items()):
        body = ' '.join(f'char {f}[256];' for f in sorted(fields))
        decls.append(f'struct {{ {body} }} {var};')
    for var, fields in sorted(hv['ind_structs'].items()):
        body = ' '.join(f'short {f};' for f in sorted(fields))
        decls.append(f'struct {{ {body} }} {var};')

    preamble = []
    m = _CURSOR_STMT.match(stmt.replace('EXEC SQL', '', 1))
    if m and not _DECLARES_CURSOR.match(stmt.replace('EXEC SQL', '', 1)):
        preamble.append(
            f'EXEC SQL DECLARE {m.group(1)} CURSOR FOR SELECT 1;')

    header = ['EXEC SQL BEGIN DECLARE SECTION;']
    header += decls
    header += ['EXEC SQL END DECLARE SECTION;',
               'int main(void)',
               '{']
    header += preamble
    offset = len(header)
    src = '\n'.join(header) + '\n' + stmt + '\nreturn 0;\n}\n'
    return src, offset, ''


_ERR_LINE = re.compile(r'\.pgc:(\d+):\s*(ERROR|WARNING):\s*(.*)$')


def validate_ecpg(statement: str, timeout: int = 30) -> dict:
    """Precompile-check one EXEC SQL statement with ``ecpg -C ORACLE``.

    Args:
        statement: One EXEC SQL statement (with or without the
            ``EXEC SQL`` prefix / trailing ``;``). SQL semantics are NOT
            checked — pair with ``validate_pg_sql`` on the inner SQL.
        timeout: Subprocess timeout in seconds.

    Returns:
        dict with ``clean`` (bool — no ERROR lines), ``issues`` (list of
        {issue, hint, severity, line}), ``ecpg_available`` (bool),
        ``skipped`` (bool) + ``skip_reason`` (str) when the scaffold
        cannot represent the statement, and ``scaffold`` (str, for
        debugging).
    """
    with correlation_id() as cid:
        bin_path = _resolve_ecpg_bin()
        if not bin_path:
            _logger.warning('validate_ecpg.unavailable', extra={})
            return {'clean': True, 'issues': [], 'ecpg_available': False,
                    'skipped': False, 'skip_reason': '', 'scaffold': ''}
        _log_version_once(bin_path)

        if not statement or not statement.strip():
            return {'clean': True, 'issues': [], 'ecpg_available': True,
                    'skipped': False, 'skip_reason': '', 'scaffold': ''}

        scaffold, offset, skip_reason = build_scaffold(statement)
        if skip_reason:
            _logger.info('validate_ecpg.skipped',
                         extra={'reason': skip_reason})
            return {'clean': True, 'issues': [], 'ecpg_available': True,
                    'skipped': True, 'skip_reason': skip_reason,
                    'scaffold': ''}

        with tempfile.TemporaryDirectory(prefix='opms-ecpg-') as td:
            pgc = os.path.join(td, 'stmt.pgc')
            out_c = os.path.join(td, 'stmt.c')
            with open(pgc, 'w', encoding='utf-8') as f:
                f.write(scaffold)
            try:
                r = subprocess.run(
                    [bin_path, '-C', 'ORACLE', '-o', out_c, pgc],
                    capture_output=True, text=True, timeout=timeout)
            except subprocess.TimeoutExpired:
                return {'clean': False,
                        'issues': [{'issue': f'ecpg timeout after {timeout}s',
                                    'hint': '', 'severity': 'error',
                                    'line': 0}],
                        'ecpg_available': True, 'skipped': False,
                        'skip_reason': '', 'scaffold': scaffold}
            except OSError as e:
                _logger.warning('validate_ecpg.exec_error',
                                extra={'err': str(e)})
                return {'clean': True, 'issues': [],
                        'ecpg_available': False, 'skipped': False,
                        'skip_reason': '', 'scaffold': scaffold}

        issues = []
        for line in (r.stderr or '').splitlines():
            m = _ERR_LINE.search(line)
            if not m:
                continue
            lineno = max(int(m.group(1)) - offset, 0)
            severity = 'error' if m.group(2) == 'ERROR' else 'warning'
            issues.append({
                'issue': f'ecpg: {m.group(3).strip()}',
                'hint': ('Fix the EXEC SQL wrapper syntax so the ECPG '
                         'precompiler accepts it (see domain-proc-to-ecpg).'
                         if severity == 'error' else ''),
                'severity': severity,
                'line': lineno,
            })
        has_error = (r.returncode != 0
                     or any(i['severity'] == 'error' for i in issues))
        if r.returncode != 0 and not issues:
            issues.append({'issue': f'ecpg exited {r.returncode}: '
                                    f'{(r.stderr or "").strip()[:200]}',
                           'hint': '', 'severity': 'error', 'line': 0})
        result = {'clean': not has_error, 'issues': issues,
                  'ecpg_available': True, 'skipped': False,
                  'skip_reason': '', 'scaffold': scaffold}
        _logger.info('validate_ecpg done',
                     extra={'clean': result['clean'],
                            'issue_count': len(issues),
                            'correlation_id': cid})
        return result
