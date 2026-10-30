"""Rule-based SQL converter for Classification A items.
Applies deterministic Oracle→PostgreSQL transformations to SQL text fragments.
"""
import re


def apply_rules(sql: str) -> str:
    """Apply all A-classification conversion rules to a SQL fragment."""
    sql = _nvl(sql)
    sql = _nvl2(sql)
    sql = _decode(sql)
    sql = _sysdate(sql)
    sql = _systimestamp(sql)
    sql = _from_dual(sql)
    sql = _substr(sql)
    sql = _instr(sql)
    sql = _trunc_date(sql)
    sql = _trunc_number(sql)
    sql = _add_months(sql)
    sql = _last_day(sql)
    sql = _to_date(sql)
    sql = _to_number(sql)
    sql = _listagg(sql)
    sql = _minus(sql)
    sql = _sequence(sql)
    sql = _sys_guid(sql)
    sql = _rownum(sql)
    sql = _hints(sql)
    sql = _months_between(sql)
    sql = _lnnvl(sql)
    sql = _ora_hash(sql)
    sql = _empty_lob(sql)
    return sql


# --- individual rules ---

def _nvl(sql):
    # NVL(a, b) → COALESCE(a, b)
    return re.sub(r'\bNVL\s*\(', 'COALESCE(', sql, flags=re.IGNORECASE)


def _nvl2(sql):
    # NVL2(a, b, c) → CASE WHEN a IS NOT NULL THEN b ELSE c END
    def _replace(m):
        inner = m.group(1)
        args = _split_args(inner)
        if len(args) == 3:
            return f'CASE WHEN {args[0].strip()} IS NOT NULL THEN {args[1].strip()} ELSE {args[2].strip()} END'
        return m.group(0)
    return re.sub(r'\bNVL2\s*\(([^()]*(?:\([^()]*\)[^()]*)*)\)', _replace, sql, flags=re.IGNORECASE)


def _decode(sql):
    # DECODE(expr, s1, r1, s2, r2, ..., default) → CASE expr WHEN s1 THEN r1 ... ELSE default END
    def _replace(m):
        args = _split_args(m.group(1))
        if len(args) < 3:
            return m.group(0)
        expr = args[0].strip()
        pairs = args[1:]
        case = f'CASE {expr}'
        i = 0
        while i + 1 < len(pairs):
            case += f' WHEN {pairs[i].strip()} THEN {pairs[i+1].strip()}'
            i += 2
        if i < len(pairs):
            case += f' ELSE {pairs[i].strip()}'
        case += ' END'
        return case
    return re.sub(r'\bDECODE\s*\(([^()]*(?:\([^()]*\)[^()]*)*)\)', _replace, sql, flags=re.IGNORECASE)


def _sysdate(sql):
    return re.sub(r'\bSYSDATE\b', 'aws_oracle_ext.sysdate()', sql, flags=re.IGNORECASE)


def _systimestamp(sql):
    return re.sub(r'\bSYSTIMESTAMP\b', 'aws_oracle_ext.sysdate()', sql, flags=re.IGNORECASE)


def _from_dual(sql):
    return re.sub(r'\bFROM\s+DUAL\b', '', sql, flags=re.IGNORECASE)


def _substr(sql):
    # SUBSTR(s, pos, len) → SUBSTRING(s FROM pos FOR len)
    # SUBSTR(s, pos) → SUBSTRING(s FROM pos)
    def _replace(m):
        args = _split_args(m.group(1))
        if len(args) == 3:
            return f'SUBSTRING({args[0].strip()} FROM {args[1].strip()} FOR {args[2].strip()})'
        elif len(args) == 2:
            return f'SUBSTRING({args[0].strip()} FROM {args[1].strip()})'
        return m.group(0)
    return re.sub(r'\bSUBSTR\s*\(([^()]*(?:\([^()]*\)[^()]*)*)\)', _replace, sql, flags=re.IGNORECASE)


def _instr(sql):
    # INSTR(s, sub) → POSITION(sub IN s)  (simple 2-arg case only)
    def _replace(m):
        args = _split_args(m.group(1))
        if len(args) == 2:
            return f'POSITION({args[1].strip()} IN {args[0].strip()})'
        return m.group(0)  # 3/4-arg INSTR needs custom function — leave as-is
    return re.sub(r'\bINSTR\s*\(([^()]*(?:\([^()]*\)[^()]*)*)\)', _replace, sql, flags=re.IGNORECASE)


def _trunc_date(sql):
    # TRUNC(date_expr) → DATE_TRUNC('day', date_expr)
    # Only when argument looks like a date expression (contains SYSDATE/date/timestamp keywords)
    def _replace(m):
        arg = m.group(1).strip()
        if re.search(r'\bsysdate\b|\bdate\b|\btimestamp\b|\bmonth\b|\byear\b', arg, re.IGNORECASE):
            return f"DATE_TRUNC('day', {arg})"
        return m.group(0)  # numeric TRUNC stays as-is
    return re.sub(r'\bTRUNC\s*\(([^()]*(?:\([^()]*\)[^()]*)*)\)', _replace, sql, flags=re.IGNORECASE)


def _trunc_number(sql):
    # TRUNC(number) stays as TRUNC — already same in PostgreSQL
    return sql


def _add_months(sql):
    # ADD_MONTHS(d, n) → d + INTERVAL 'n months'  (literal n only)
    def _replace(m):
        args = _split_args(m.group(1))
        if len(args) == 2:
            d, n = args[0].strip(), args[1].strip()
            if re.match(r'^-?\d+$', n):
                return f"{d} + INTERVAL '{n} months'"
            return f"{d} + ({n} * INTERVAL '1 month')"
        return m.group(0)
    return re.sub(r'\bADD_MONTHS\s*\(([^()]*(?:\([^()]*\)[^()]*)*)\)', _replace, sql, flags=re.IGNORECASE)


def _last_day(sql):
    # LAST_DAY(d) → (DATE_TRUNC('month', d) + INTERVAL '1 month - 1 day')::DATE
    def _replace(m):
        d = m.group(1).strip()
        return f"(DATE_TRUNC('month', {d}) + INTERVAL '1 month - 1 day')::DATE"
    return re.sub(r'\bLAST_DAY\s*\(([^()]*(?:\([^()]*\)[^()]*)*)\)', _replace, sql, flags=re.IGNORECASE)


def _to_date(sql):
    # TO_DATE(s, fmt) → TO_TIMESTAMP(s, fmt)
    return re.sub(r'\bTO_DATE\s*\(', 'TO_TIMESTAMP(', sql, flags=re.IGNORECASE)


def _to_number(sql):
    # TO_NUMBER(s) → CAST(s AS NUMERIC)  (simple 1-arg case)
    def _replace(m):
        args = _split_args(m.group(1))
        if len(args) == 1:
            return f'CAST({args[0].strip()} AS NUMERIC)'
        return m.group(0)
    return re.sub(r'\bTO_NUMBER\s*\(([^()]*(?:\([^()]*\)[^()]*)*)\)', _replace, sql, flags=re.IGNORECASE)


def _listagg(sql):
    # LISTAGG(col, sep) WITHIN GROUP (ORDER BY ...) → STRING_AGG(col, sep ORDER BY ...)
    def _replace(m):
        args = _split_args(m.group(1))
        order = m.group(2).strip()
        if len(args) >= 2:
            return f'STRING_AGG({args[0].strip()}, {args[1].strip()} {order})'
        return m.group(0)
    return re.sub(
        r'\bLISTAGG\s*\(([^()]*(?:\([^()]*\)[^()]*)*)\)\s*WITHIN\s+GROUP\s*\((ORDER\s+BY[^)]*)\)',
        _replace, sql, flags=re.IGNORECASE)


def _minus(sql):
    return re.sub(r'\bMINUS\b', 'EXCEPT', sql, flags=re.IGNORECASE)


def _sequence(sql):
    # schema.seq.NEXTVAL → nextval('schema.seq')
    # schema.seq.CURRVAL → currval('schema.seq')
    sql = re.sub(r'(\w+(?:\.\w+)?)\.NEXTVAL\b',
                 lambda m: f"nextval('{m.group(1)}')", sql, flags=re.IGNORECASE)
    sql = re.sub(r'(\w+(?:\.\w+)?)\.CURRVAL\b',
                 lambda m: f"currval('{m.group(1)}')", sql, flags=re.IGNORECASE)
    return sql


def _sys_guid(sql):
    return re.sub(r'\bSYS_GUID\s*\(\s*\)', 'gen_random_uuid()', sql, flags=re.IGNORECASE)


def _rownum(sql):
    # Simple ROWNUM pagination: WHERE ROWNUM <= n → LIMIT n  (top-level only, heuristic)
    # More complex cases left to LLM (B classification)
    # Remove preceding AND/OR when ROWNUM is not the only WHERE condition
    sql = re.sub(r'\bAND\s+ROWNUM\b\s*<=\s*(\d+)', r'LIMIT \1', sql, flags=re.IGNORECASE)
    sql = re.sub(r'\bAND\s+ROWNUM\b\s*<\s*(\d+)', lambda m: f'LIMIT {int(m.group(1))-1}', sql, flags=re.IGNORECASE)
    # WHERE ROWNUM as sole condition → remove WHERE, add LIMIT
    sql = re.sub(r'\bWHERE\s+ROWNUM\b\s*<=\s*(\d+)', r'LIMIT \1', sql, flags=re.IGNORECASE)
    sql = re.sub(r'\bWHERE\s+ROWNUM\b\s*<\s*(\d+)', lambda m: f'LIMIT {int(m.group(1))-1}', sql, flags=re.IGNORECASE)
    # Fallback: bare ROWNUM (e.g. in SELECT list)
    sql = re.sub(r'\bROWNUM\b\s*<=\s*(\d+)', r'LIMIT \1', sql, flags=re.IGNORECASE)
    sql = re.sub(r'\bROWNUM\b\s*<\s*(\d+)', lambda m: f'LIMIT {int(m.group(1))-1}', sql, flags=re.IGNORECASE)
    return sql


def _hints(sql):
    # Remove Oracle optimizer hints /*+ ... */
    return re.sub(r'/\*\+[^*]*\*/', '', sql)


def _months_between(sql):
    # MONTHS_BETWEEN(d1, d2) → EXTRACT(EPOCH FROM age(d1, d2)) / 2592000
    def _replace(m):
        args = _split_args(m.group(1))
        if len(args) == 2:
            return f'EXTRACT(EPOCH FROM age({args[0].strip()}, {args[1].strip()})) / 2592000'
        return m.group(0)
    return re.sub(r'\bMONTHS_BETWEEN\s*\(([^()]*(?:\([^()]*\)[^()]*)*)\)', _replace, sql, flags=re.IGNORECASE)


def _lnnvl(sql):
    # LNNVL(expr) → NOT (expr) IS NOT FALSE
    def _replace(m):
        return f'NOT ({m.group(1).strip()}) IS NOT FALSE'
    return re.sub(r'\bLNNVL\s*\(([^()]*(?:\([^()]*\)[^()]*)*)\)', _replace, sql, flags=re.IGNORECASE)


def _ora_hash(sql):
    # ORA_HASH(expr) → hashtext(expr::TEXT), ORA_HASH(expr, n) → mod(abs(hashtext(expr::TEXT)), n+1)
    def _replace(m):
        args = _split_args(m.group(1))
        if len(args) == 1:
            return f'hashtext({args[0].strip()}::TEXT)'
        elif len(args) == 2:
            return f'mod(abs(hashtext({args[0].strip()}::TEXT)), {args[1].strip()} + 1)'
        return m.group(0)
    return re.sub(r'\bORA_HASH\s*\(([^()]*(?:\([^()]*\)[^()]*)*)\)', _replace, sql, flags=re.IGNORECASE)

def _split_args(s: str) -> list[str]:
    """Split comma-separated function arguments respecting parentheses and single-quoted strings."""
    args, depth, in_quote, cur = [], 0, False, []
    for ch in s:
        if ch == "'" and depth == 0:
            in_quote = not in_quote
        elif not in_quote:
            if ch == '(':
                depth += 1
            elif ch == ')':
                depth -= 1
        if ch == ',' and depth == 0 and not in_quote:
            args.append(''.join(cur))
            cur = []
        else:
            cur.append(ch)
    if cur:
        args.append(''.join(cur))
    return args


def _empty_lob(sql):
    # empty_clob() / empty_blob() → ''
    return re.sub(r'\bempty_[cb]lob\s*\(\s*\)', "''", sql, flags=re.IGNORECASE)


def convert_oracle_sql_rules(sql: str) -> dict:
    """MCP tool entry point: apply deterministic Oracle→PostgreSQL rules.

    Thin wrapper around ``apply_rules``. If no rule applies, the original
    text is returned unchanged (``changed=False``).

    Args:
        sql: Oracle SQL/PL-SQL text fragment.

    Returns:
        dict with ``converted_sql`` (str) and ``changed`` (bool).
    """
    converted = apply_rules(sql)
    return {'converted_sql': converted, 'changed': converted != sql}

