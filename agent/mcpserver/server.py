from mcp.server.fastmcp import FastMCP
from oracle import run_ora_sql
from postgres import run_pg_sql
from shell import run_shell
try:
    from utils.logger import setup_logger
except ImportError:
    import os
    import sys

    sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    from utils.logger import setup_logger

logger = setup_logger("oracle")

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
    return run_ora_sql(sql)

@mcp.tool()
def run_postgres_sql(sql):
    """
    Execute SQL query on PostgreSQL database.

    Args:
        sql (str): SQL query to execute on the PostgreSQL database.

    Returns:
        dict: Query execution results from the PostgreSQL database.
    """
    return run_pg_sql(sql)

@mcp.tool()
def shell(command):
    """
    Execute shell command.

    Args:
        command (str): Shell command to execute

    Returns:
        str: Command output
    """
    return run_shell(command)

if __name__ == "__main__":
    mcp.run(transport="stdio")
