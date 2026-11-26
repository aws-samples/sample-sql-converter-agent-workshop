"""Strip dynamic-SQL wrapper syntax from ORM / SQL-template source.

Supports:
- MyBatis dynamic tags (<if>, <where>, <choose>, <foreach>, <trim>, <set>,
  <bind>, <include>, <selectKey>, <sql>)
- MyBatis / iBATIS statement wrappers (<select>, <insert>, <update>, <delete>,
  <mapper>, <parameterMap>, <resultMap>, <dynamic>, <is*>, <iterate>)
- Hibernate query wrappers (<query>, <sql-query>, <named-query>, <return>,
  <return-scalar>, <return-property>, <param>, <synchronize>)
- Seasar2 / S2Dao SQL comment directives
  (/*IF*/, /*ELSE*/, /*END*/, /*BEGIN*/, /*FOR item : list*/, /*$var*/'dummy',
   /* var */'dummy')

Operates outside of single-quoted string literals.
"""

import re


# ---- XML tag name sets ----------------------------------------------------

_MYBATIS_DYNAMIC = (
    'if', 'choose', 'when', 'otherwise', 'foreach', 'trim', 'set',
    'bind', 'include', 'selectKey', 'sql',
)
_MYBATIS_IBATIS_STMT = (
    'select', 'insert', 'update', 'delete', 'mapper',
    'parameterMap', 'resultMap', 'dynamic', 'iterate',
)
_IBATIS_LEGACY_COND = (
    'isEqual', 'isNotEqual', 'isEmpty', 'isNotEmpty',
    'isNull', 'isNotNull', 'isPropertyAvailable', 'isGreaterThan',
    'isLessThan', 'isGreaterEqual', 'isLessEqual',
)
_HIBERNATE = (
    'query', 'sql-query', 'named-query',
    'return', 'return-scalar', 'return-property', 'return-join',
    'param', 'synchronize',
)

_ALL_TAGS = _MYBATIS_DYNAMIC + _MYBATIS_IBATIS_STMT + _IBATIS_LEGACY_COND + _HIBERNATE
_TAG_UNION = '|'.join(re.escape(t) for t in _ALL_TAGS)

_TAG_RE = re.compile(rf'</?\s*(?:{_TAG_UNION})\b[^<>]*/?>', re.IGNORECASE)
_WHERE_OPEN_RE = re.compile(r'<\s*where\b[^<>]*>', re.IGNORECASE)
_WHERE_CLOSE_RE = re.compile(r'</\s*where\s*>', re.IGNORECASE)


# ---- S2Dao / Seasar2 comment directives -----------------------------------

# Block controls: /*IF cond*/, /*ELSE*/, /*ELSEIF ...*/, /*BEGIN*/, /*FOR item : list*/, /*END*/
_S2DAO_BLOCK_RE = re.compile(
    r'/\*\s*(IF|ELSEIF|ELSE|BEGIN|END|FOR)\b[^*]*?\*/',
    re.IGNORECASE,
)
# Embedded identifier: /*$name*/DUMMY — keep the dummy value as a placeholder
_S2DAO_EMBED_IDENT_RE = re.compile(
    r'/\*\s*\$[A-Za-z_][\w.]*\s*\*/',
)
# Bind variable: /* name */DUMMY — strip only the comment, keep the dummy
_S2DAO_BIND_RE = re.compile(
    r'/\*\s*[A-Za-z_][\w.]*\s*\*/',
)


# ---- Public API -----------------------------------------------------------

def strip_dynamic_sql_wrappers(sql: str) -> str:
    """Remove ORM wrapper tags and S2Dao comment directives from a SQL fragment.

    Preserves single-quoted string literals verbatim.
    """
    return _outside_strings(sql, _strip_segment)


# ---- Implementation -------------------------------------------------------

def _strip_segment(seg: str) -> str:
    # <where>...</where>  →  WHERE ... (and drop leading AND/OR)
    seg = _WHERE_OPEN_RE.sub(' WHERE ', seg)
    seg = _WHERE_CLOSE_RE.sub(' ', seg)
    # All other supported XML tags
    seg = _TAG_RE.sub(' ', seg)
    seg = re.sub(r'(?i)\bWHERE\b\s+(?:AND|OR)\b', 'WHERE', seg)
    # S2Dao: block controls drop entirely
    seg = _S2DAO_BLOCK_RE.sub(' ', seg)
    # S2Dao: /*$name*/  drop, leaving the dummy identifier/literal as-is
    seg = _S2DAO_EMBED_IDENT_RE.sub('', seg)
    # S2Dao: /* name */  drop, leaving the dummy value as-is
    seg = _S2DAO_BIND_RE.sub('', seg)
    return seg


def _outside_strings(s: str, apply) -> str:
    """Apply ``apply`` only to regions outside single-quoted string literals.

    PostgreSQL escape rules: doubled single quotes ('') inside a literal
    represent a single quote and do NOT end the literal.
    """
    out, i, n = [], 0, len(s)
    while i < n:
        c = s[i]
        if c == "'":
            out.append(c)
            i += 1
            while i < n:
                out.append(s[i])
                if s[i] == "'":
                    if i + 1 < n and s[i + 1] == "'":
                        out.append("'")
                        i += 2
                        continue
                    i += 1
                    break
                i += 1
        else:
            j = s.find("'", i)
            if j == -1:
                out.append(apply(s[i:]))
                break
            out.append(apply(s[i:j]))
            i = j
    return ''.join(out)
