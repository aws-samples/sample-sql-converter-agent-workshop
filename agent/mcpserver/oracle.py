import json
import boto3
import oracledb
import os
import sys

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from utils.logger import setup_logger

logger = setup_logger("oracle")
secret_manager = boto3.client("secretsmanager")

def get_db_credentials():
    """
    Get Oracle database credentials from AWS Secrets Manager and IP address from CDK output.

    Returns:
        dict: Database connection credentials including user, password, and IP address

    Raises:
        Exception: If credentials retrieval fails
    """
    secret_response = json.loads(
        secret_manager.get_secret_value(SecretId="oracle-credentials")["SecretString"]
    )
    user = secret_response["username"]
    password = secret_response["password"]

    dsn = oracledb.makedsn(host="localhost", port=11521, service_name="XEPDB1")

    return {
        "user": user,
        "password": password,
        "dsn": dsn,
    }

def execute_query(sql):
    """
    Execute SQL query on Oracle database.

    Args:
        sql (str): SQL query to execute

    Returns:
        list: Query execution results

    Raises:
        Exception: If query execution fails
    """
    credentials = get_db_credentials()
    connection = None
    cursor = None
    try:
        connection = oracledb.connect(
            user=credentials["user"],
            password=credentials["password"],
            dsn=credentials["dsn"],
        )
        cursor = connection.cursor()
        cursor.execute(sql)

        # 結果セット取得を安全に試行
        query_result = []
        try:
            response = cursor.fetchall()

            # LOBオブジェクトの処理
            processed_response = []
            for row in response:
                processed_row = []
                for item in row:
                    if hasattr(item, 'read'):
                        try:
                            lob_data = item.read()
                            if isinstance(lob_data, bytes):
                                lob_data = lob_data.decode('utf-8', errors='ignore')
                            processed_row.append(lob_data)
                        except Exception as e:
                            logger.error(f"Error reading LOB: {e}")
                            processed_row.append(str(item))
                    else:
                        processed_row.append(item)
                processed_response.append(tuple(processed_row))

            query_result = processed_response

        except Exception:
            # INSERT/UPDATE/DELETE/CREATE/DROP文など結果セットがない場合
            logger.info("Statement executed (no result set to fetch)")
            query_result = []

        connection.commit()
        logger.info("Transaction committed")

        return query_result

    except Exception as e:
        logger.error(f"Error executing query: {e}")
        if connection:
            connection.rollback()
        raise
    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()

def oracle_execute(sql):
    """
    Execute SQL query on Oracle database.

    Args:
        sql (str): SQL query to execute on the Oracle database.

    Returns:
        list: Query execution results from the Oracle database.
    """
    logger.info(f"Executing: {sql}")
    response = execute_query(sql)
    logger.info("Query completed")
    return response
