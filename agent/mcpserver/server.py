import json
import os
import time

from mcp.server.fastmcp import FastMCP
from oracle import oracle_execute
from postgres import postgres_check, postgres_execute
from shell import mkdir_p

try:
    from utils.logger import get_logger
    from utils.session import exec_log_path
except ImportError:
    import sys

    sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    from utils.logger import get_logger
    from utils.session import exec_log_path

logger = get_logger("server")

# Execution log (one file per chat session) shared with the scaw_tools MCP
# server: write_app_convert_outputs checks that the converted SQL was actually
# run on both Oracle and PostgreSQL.
EXEC_LOG = exec_log_path()


def _log_execution(db):
    try:
        with open(EXEC_LOG, "a", encoding="utf-8") as f:
            f.write(json.dumps({"db": db, "ts": time.time()}) + "\n")
    except OSError as e:
        logger.warning(f"could not write execution log: {e}")

mcp = FastMCP("sql-converter")


@mcp.tool()
def run_ora_sql(sql):
    """
    Execute SQL query on Oracle database.

    Args:
        sql (str): SQL query to execute on the Oracle database.

    Returns:
        list: Query execution results from the Oracle database.
    """
    result = oracle_execute(sql)  # raises on error; only successful runs are logged
    _log_execution("oracle")
    return result


@mcp.tool()
def run_postgres_sql(sql):
    """
    Execute SQL on the Aurora PostgreSQL database (direct connection).

    Several statements separated by semicolons can be sent in one call.
    RAISE NOTICE messages are returned in "notices", so a DO block can report
    comparison values with RAISE NOTICE instead of RAISE EXCEPTION.
    Statements run in autocommit mode, but several statements sent in one
    call run as one implicit transaction. A CALL of a procedure that issues
    COMMIT / ROLLBACK must therefore be sent alone in its own call (otherwise
    it fails with "invalid transaction termination"); check the results with
    a separate call.

    Args:
        sql (str): SQL to execute on the PostgreSQL database.

    Returns:
        dict: {"results": [{"status", "row_count", "columns", "rows"}, ...],
        "notices": [...]}. One entry in "results" per statement.
    """
    result = postgres_execute(sql)  # raises on error; only successful runs are logged
    _log_execution("postgres")
    return result


@mcp.tool()
def check_postgres_sql(sql, search_path=""):
    """
    Check converted SQL on Aurora PostgreSQL without changing anything.

    The check runs in a transaction that is always rolled back. A single
    SELECT / INSERT / UPDATE / DELETE / WITH is checked with PREPARE (syntax,
    table and column names, types; not executed; write placeholders as
    $1..$n). Other SQL (CREATE FUNCTION / PROCEDURE / VIEW, DO blocks, ...) is
    executed and rolled back. CALL is not supported.

    Use it to find errors quickly while fixing a conversion, before the real
    test with run_postgres_sql. It is not an execution test: it does not count
    as running the SQL on PostgreSQL.

    Args:
        sql (str): SQL to check.
        search_path (str): Optional schema search path for the check
            (e.g. "schema_sample").

    Returns:
        dict: {"ok": true, "method"} or {"ok": false, "method", "sqlstate",
        "message", "position"}. Compare sqlstate + message with the previous
        attempt to tell whether a fix changed the error.
    """
    return postgres_check(sql, search_path)


@mcp.tool()
def create_directory(path):
    """
    Create directory and all parent directories if they don't exist (mkdir -p equivalent).

    Args:
        path (str): Directory path to create

    Returns:
        str: Success or error message
    """
    return mkdir_p(path)


if __name__ == "__main__":
    mcp.run(transport="stdio")
