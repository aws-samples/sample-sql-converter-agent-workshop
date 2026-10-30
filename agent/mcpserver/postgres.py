"""Run SQL on Aurora PostgreSQL over a direct connection (psycopg).

The Oracle EC2 instance and the Aurora cluster are in the same VPC, and the
Aurora security group allows the instance's security group on the PostgreSQL
port, so the agent connects directly instead of going through the RDS Data
API. Credentials (host, port, username, password) come from the Secrets
Manager secret ``aurora-pg-credentials``.

Compared with the RDS Data API, a direct connection also returns
``RAISE NOTICE`` messages (``notices``) and accepts several statements in one
call, which makes before/after comparison tests easier.
"""
import datetime
import decimal
import json
import os
import sys
import uuid

import boto3
import psycopg

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from utils.logger import get_logger

logger = get_logger("postgres")

SECRET_ID = "aurora-pg-credentials"
DATABASE = "postgres"
CONNECT_TIMEOUT_SECONDS = 10
STATEMENT_TIMEOUT_MS = 300_000  # 5 minutes
MAX_ROWS = 1000  # rows returned per result set (the rest are counted but not returned)


def get_db_credentials():
    """
    AWS Secrets Manager から Aurora PostgreSQL の接続情報を取得する

    Returns:
        dict: host, port, user, password, dbname

    Raises:
        Exception: 認証情報の取得に失敗した場合
    """
    try:
        logger.info("Retrieving database credentials from Secrets Manager")
        secret = json.loads(
            boto3.client("secretsmanager").get_secret_value(SecretId=SECRET_ID)[
                "SecretString"
            ]
        )
        return {
            "host": secret["host"],
            "port": int(secret.get("port", 5432)),
            "user": secret["username"],
            "password": secret["password"],
            "dbname": DATABASE,
        }
    except Exception as e:
        logger.error(f"Failed to get credentials: {str(e)}", exc_info=True)
        raise Exception(f"Failed to get credentials: {str(e)}")


def _to_json_value(value):
    """Convert a value returned by psycopg into a JSON-serializable value."""
    if value is None or isinstance(value, (bool, int, float, str)):
        return value
    if isinstance(value, decimal.Decimal):
        return str(value)  # keep the exact precision
    if isinstance(value, (datetime.date, datetime.time, datetime.datetime)):
        return value.isoformat()
    if isinstance(value, (bytes, bytearray, memoryview)):
        return "\\x" + bytes(value).hex()
    if isinstance(value, (list, tuple)):
        return [_to_json_value(v) for v in value]
    if isinstance(value, dict):
        return {str(k): _to_json_value(v) for k, v in value.items()}
    if isinstance(value, (uuid.UUID, datetime.timedelta)):
        return str(value)
    return str(value)


def _collect_result(cursor):
    """Return one result set of the current cursor position as a dict."""
    result = {"status": cursor.statusmessage, "row_count": cursor.rowcount}
    if cursor.description is not None:
        result["columns"] = [col.name for col in cursor.description]
        rows = cursor.fetchall()
        result["rows"] = [[_to_json_value(v) for v in row] for row in rows[:MAX_ROWS]]
        if len(rows) > MAX_ROWS:
            result["truncated"] = True
            result["total_rows"] = len(rows)
    return result


def execute_query(credentials, sql):
    """
    Aurora PostgreSQL に直接接続して SQL を実行する

    Args:
        credentials (dict): データベース接続情報
        sql (str): 実行する SQL（複数の文をセミコロンで区切って渡してもよい）

    Returns:
        dict: {"results": [文ごとの結果], "notices": [RAISE NOTICE 等のメッセージ]}

    Raises:
        Exception: クエリ実行に失敗した場合（SQLSTATE を含むメッセージ）
    """
    notices = []
    try:
        logger.info("Executing query on Aurora PostgreSQL (direct connection)")
        logger.info(f"Query: {sql}")
        with psycopg.connect(
            **credentials,
            sslmode="require",
            connect_timeout=CONNECT_TIMEOUT_SECONDS,
            options=f"-c statement_timeout={STATEMENT_TIMEOUT_MS}",
            autocommit=True,
        ) as conn:
            conn.add_notice_handler(
                lambda diag: notices.append(
                    f"{diag.severity}: {diag.message_primary}"
                )
            )
            # ClientCursor uses the simple query protocol, so several
            # statements can be sent in one call (as with psql).
            with psycopg.ClientCursor(conn) as cursor:
                cursor.execute(sql)
                results = [_collect_result(cursor)]
                while cursor.nextset():
                    results.append(_collect_result(cursor))
        response = {"results": results, "notices": notices}
        logger.info("Query executed successfully")
        logger.info(f"Query response: {response}")
        return response
    except psycopg.Error as e:
        sqlstate = getattr(e, "sqlstate", None)
        message = f"{str(e).strip()}"
        if sqlstate:
            message += f" (SQLSTATE: {sqlstate})"
        if notices:
            message += f" | notices before the error: {notices}"
        logger.error(f"Failed to execute query: {message}", exc_info=True)
        raise Exception(message)
    except Exception as e:
        logger.error(f"Failed to execute query: {str(e)}", exc_info=True)
        raise Exception(str(e))


def postgres_execute(sql):
    """
    Execute SQL on the Aurora PostgreSQL database over a direct connection.

    Retrieves the connection information from AWS Secrets Manager, connects
    with psycopg (TLS, autocommit), and executes the SQL.

    Args:
        sql (str): SQL to execute. Several statements separated by semicolons
            are allowed.

    Returns:
        dict: {"results": [{"status", "row_count", "columns", "rows"}, ...],
        "notices": [...]}

    Raises:
        Exception: If there is an error retrieving credentials or executing the query.
    """
    try:
        logger.info("Starting SQL execution")
        credentials = get_db_credentials()
        response = execute_query(credentials, sql)
        logger.info("SQL execution completed successfully")
        return response
    except Exception as e:
        logger.error(f"SQL execution failed: {str(e)}", exc_info=True)
        raise Exception(str(e))
