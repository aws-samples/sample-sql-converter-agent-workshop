from mcp.server.fastmcp import FastMCP
from oracle import oracle_execute
from postgres import postgres_execute
from shell import mkdir_p

try:
    from utils.logger import get_logger
except ImportError:
    import os
    import sys

    sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    from utils.logger import get_logger

logger = get_logger("server")

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
    return oracle_execute(sql)


@mcp.tool()
def run_postgres_sql(sql):
    """
    Execute SQL on the Aurora PostgreSQL database (direct connection).

    Several statements separated by semicolons can be sent in one call.
    RAISE NOTICE messages are returned in "notices", so a DO block can report
    comparison values with RAISE NOTICE instead of RAISE EXCEPTION.
    Statements run in autocommit mode.

    Args:
        sql (str): SQL to execute on the PostgreSQL database.

    Returns:
        dict: {"results": [{"status", "row_count", "columns", "rows"}, ...],
        "notices": [...]}. One entry in "results" per statement.
    """
    return postgres_execute(sql)


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
