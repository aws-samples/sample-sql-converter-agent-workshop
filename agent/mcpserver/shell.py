import os
import subprocess
import sys

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from utils.logger import setup_logger

logger = setup_logger("shell")

def shell_execute(command):
    """
    Execute shell command.

    Args:
        command (str): Shell command to execute

    Returns:
        str: Command output
    """
    logger.info(f"Executing: {command}")
    try:
        result = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True,
            timeout=30,
            cwd=os.getcwd(),
        )

        output = ""
        if result.stdout:
            output += result.stdout
        if result.stderr:
            output += result.stderr

        return output

    except subprocess.TimeoutExpired:
        logger.error(f"Command timed out: {command}")
        return f"Command timed out after 30 seconds: {command}"
    except Exception as e:
        logger.error(f"Error executing command: {e}")
        return f"Error executing command: {e}"
