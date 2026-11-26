"""Regex-based detection of Oracle residuals in post-conversion SQL."""

import re

from oracle_hints import ORACLE_FEATURES
from _validator_consts import (
    CONVERSION_HINTS,
    PG_COMPATIBLE_NAMES,
    PG_CUSTOM_FUNC_NAMES,
    VALIDATOR_EXTRA_FEATURES,
)


# Pre-compile the full pattern set once at import time.
_FEATURE_CHECKS = [
    (name, re.compile(pat, re.IGNORECASE), cls)
    for name, pat, cls in list(ORACLE_FEATURES) + VALIDATOR_EXTRA_FEATURES
]


def detect_residuals(sql: str) -> list[dict]:
    """Return residual Oracle features in ``sql`` as a list of issue dicts.

    Each issue dict has ``issue``, ``hint``, ``severity`` keys.
    Only occurrences that are NOT schema-qualified and NOT PG-custom-function
    calls are reported.
    """
    issues: list[dict] = []
    for name, pattern, cls in _FEATURE_CHECKS:
        if name in PG_COMPATIBLE_NAMES:
            continue
        matches = list(pattern.finditer(sql))
        if not matches or all(_is_ignorable(sql, m, name) for m in matches):
            continue
        issues.append({
            'issue': f'Oracle feature ({cls}): {name}',
            'hint': CONVERSION_HINTS.get(name, ''),
            'severity': 'error',
        })
    return issues


def detect_manual_review_markers(sql: str) -> list[dict]:
    """Return an issue if the LLM left a MANUAL_REVIEW marker in the SQL."""
    if '-- MANUAL_REVIEW:' in sql or '/* MANUAL_REVIEW:' in sql:
        return [{
            'issue': 'MANUAL_REVIEW marker in SQL',
            'hint': 'Review the MANUAL_REVIEW comment and finalize the conversion',
            'severity': 'warning',
        }]
    return []


def _is_ignorable(sql: str, match: re.Match, name: str) -> bool:
    start, end = match.start(), match.end()
    before = sql[max(0, start - 30):start]
    # Schema-qualified (e.g. aws_oracle_ext.nvl) or column-qualified (t.SYSDATE)
    if re.search(r'[\w"]+\s*\.\s*$', before):
        return True
    # PG custom function call: bare name immediately followed by `(`
    if name in PG_CUSTOM_FUNC_NAMES and re.match(r'\s*\(', sql[end:end + 10]):
        return True
    return False
