"""Identify the Kiro CLI chat session that started this MCP server.

The scaw_tools and scaw_mcpserver MCP servers (and those of sub-agents) are
all started by the same ``kiro-cli-chat`` process, so its PID is used as the
session key. Files shared between the servers (the execution log) are kept
per session so that different chat sessions do not mix.
"""
import os
import tempfile


def session_key() -> str:
    """PID of the nearest ``kiro-cli`` ancestor process, or ``default``
    when it cannot be found (for example outside Linux)."""
    pid = os.getppid()
    for _ in range(10):
        try:
            with open(f"/proc/{pid}/stat", encoding="utf-8") as f:
                stat = f.read()
        except OSError:
            break
        # Format: "<pid> (<comm>) <state> <ppid> ..."; comm may contain spaces.
        comm = stat[stat.index("(") + 1:stat.rindex(")")]
        if comm.startswith("kiro-cli"):
            return str(pid)
        ppid = int(stat[stat.rindex(")") + 2:].split()[1])
        if ppid <= 1:
            break
        pid = ppid
    return "default"


def exec_log_path() -> str:
    """Execution log written by run_ora_sql / run_postgres_sql."""
    return os.path.join(tempfile.gettempdir(), f"scaw-exec-log-{session_key()}.jsonl")
