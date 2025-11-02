import os
import sys

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from utils.logger import get_logger

logger = get_logger("shell")

def mkdir_p(path):
    """
    Create directory and all parent directories if they don't exist (mkdir -p equivalent).

    Args:
        path (str): Directory path to create

    Returns:
        str: Success or error message
    """
    logger.info(f"Creating directory: {path}")
    try:
        os.makedirs(path, exist_ok=True)
        return f"Directory created successfully: {path}"
    except Exception as e:
        logger.error(f"Error creating directory: {e}")
        return f"Error creating directory: {e}"
