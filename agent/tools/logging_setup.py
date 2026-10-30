"""Structured logging for oracle-pg-mcp-server.

Outputs JSON Lines. Each record includes a correlation ID (per-call)
and optional tool-specific fields via ``logger.info(msg, extra={...})``.

Environment variables:
    OPMS_LOG_LEVEL  - DEBUG / INFO / WARNING / ERROR (default: INFO)
    OPMS_LOG_FILE   - Path for log output (default: stderr)

Usage:
    init_logging()
    logger = get_logger(__name__)
    with correlation_id():
        logger.info('classify start', extra={'sql_len': len(sql)})
"""

import contextvars
import json
import logging
import os
import sys
import uuid
from contextlib import contextmanager
from datetime import datetime, timezone
from typing import Iterator, Optional


_correlation_id: contextvars.ContextVar[Optional[str]] = contextvars.ContextVar(
    'oracle_pg_mcp_correlation_id', default=None
)
_STANDARD_ATTRS = frozenset(logging.LogRecord('', 0, '', 0, '', None, None).__dict__) | {
    'message', 'asctime'
}


class JsonLineFormatter(logging.Formatter):
    """Serialize log records as one JSON object per line."""

    def format(self, record: logging.LogRecord) -> str:
        payload = {
            'ts': datetime.fromtimestamp(record.created, tz=timezone.utc).isoformat(),
            'level': record.levelname,
            'logger': record.name,
            'msg': record.getMessage(),
        }
        cid = _correlation_id.get()
        if cid:
            payload['correlation_id'] = cid
        # extra={...} fields passed via logger call
        for key, value in record.__dict__.items():
            if key not in _STANDARD_ATTRS and not key.startswith('_'):
                payload[key] = value
        if record.exc_info:
            payload['exc'] = self.formatException(record.exc_info)
        return json.dumps(payload, ensure_ascii=False, default=str)


def init_logging(level: Optional[str] = None, log_file: Optional[str] = None) -> None:
    """Initialize the root logger. Safe to call multiple times."""
    level_name = (level or os.getenv('OPMS_LOG_LEVEL') or 'INFO').upper()
    target = log_file or os.getenv('OPMS_LOG_FILE')

    handler: logging.Handler
    if target:
        handler = logging.FileHandler(target, encoding='utf-8')
    else:
        handler = logging.StreamHandler(sys.stderr)
    handler.setFormatter(JsonLineFormatter())

    root = logging.getLogger()
    for h in list(root.handlers):
        root.removeHandler(h)
    root.addHandler(handler)
    root.setLevel(getattr(logging, level_name, logging.INFO))


def get_logger(name: str) -> logging.Logger:
    """Return a logger under the oracle_pg_mcp namespace."""
    return logging.getLogger(f'oracle_pg_mcp.{name}')


@contextmanager
def correlation_id(value: Optional[str] = None) -> Iterator[str]:
    """Bind a correlation ID to all logs emitted within the block."""
    cid = value or uuid.uuid4().hex[:12]
    token = _correlation_id.set(cid)
    try:
        yield cid
    finally:
        _correlation_id.reset(token)


def current_correlation_id() -> Optional[str]:
    """Return the current correlation ID if any."""
    return _correlation_id.get()
