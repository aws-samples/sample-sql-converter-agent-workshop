"""`validate_pg_sql` MCP tool.

Thin orchestrator that runs the four independent validation passes:

1. Strip ORM / dynamic SQL wrappers  (_xml_tag_stripper)
2. Normalize language placeholders   (_placeholder_normalizer)
3. Detect Oracle residuals           (_residual_detector, regex + skip rules)
4. Check PostgreSQL syntax           (_pg_parser, pglast)

Emits structured logs with a correlation ID for every call.
"""

from logging_setup import correlation_id, get_logger
from _pg_parser import HAS_PGLAST, check_pg_syntax
from _placeholder_normalizer import normalize_placeholders
from _residual_detector import (
    detect_manual_review_markers,
    detect_residuals,
)
from _xml_tag_stripper import strip_dynamic_sql_wrappers


_logger = get_logger('tools.validate_pg_sql')


def validate_pg_sql(sql: str) -> dict:
    """Check converted SQL for Oracle residuals and PostgreSQL syntax errors.

    Args:
        sql: The SQL string to check (expected to be PostgreSQL after conversion)

    Returns:
        dict with ``clean`` (bool), ``issues`` (list of {issue, hint, severity}),
        and ``pglast_available`` (bool).
    """
    with correlation_id() as cid:
        _logger.info(
            'validate_pg_sql start',
            extra={'sql_len': len(sql or ''), 'pglast': HAS_PGLAST},
        )

        if not sql or not sql.strip():
            _logger.info('validate_pg_sql.empty_input', extra={'issues_count': 0})
            return {'clean': True, 'issues': [], 'pglast_available': HAS_PGLAST}

        sql_for_parse = normalize_placeholders(strip_dynamic_sql_wrappers(sql))
        issues: list[dict] = []
        issues.extend(check_pg_syntax(sql_for_parse, sql))
        issues.extend(detect_residuals(sql))
        issues.extend(detect_manual_review_markers(sql))

        result = {
            'clean': len(issues) == 0,
            'issues': issues,
            'pglast_available': HAS_PGLAST,
        }
        _logger.info(
            'validate_pg_sql done',
            extra={
                'clean': result['clean'],
                'issues_count': len(issues),
                'correlation_id': cid,
            },
        )
        return result
