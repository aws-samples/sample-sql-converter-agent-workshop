import json
import os
import sys
import boto3

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from utils.logger import setup_logger

logger = setup_logger("postgres")

# AWS アカウント情報
sts = boto3.client("sts")
account_id = sts.get_caller_identity()["Account"]
region = sts.meta.region_name

def get_db_credentials():
    """
    AWS Secrets Manager から Aurora PostgreSQL の認証情報を取得する

    Returns:
        dict: データベース接続に必要な認証情報

    Raises:
        Exception: 認証情報の取得に失敗した場合
    """
    try:
        logger.info("Retrieving database credentials from Secrets Manager")
        secrets_client = boto3.client("secretsmanager")
        secret_response = secrets_client.get_secret_value(
            SecretId="aurora-pg-credentials"
        )

        secret = json.loads(secret_response["SecretString"])
        cluster_arn = (
            f"arn:aws:rds:{region}:{account_id}:cluster:{secret['dbClusterIdentifier']}"
        )

        logger.debug("Successfully retrieved database credentials")
        return {
            "cluster_arn": cluster_arn,
            "secret_arn": secret_response["ARN"],
            "database": "postgres",
        }
    except Exception as e:
        logger.error(f"Failed to get credentials: {str(e)}", exc_info=True)
        raise Exception(f"Failed to get credentials: {str(e)}")

def execute_query(credentials, sql):
    """
    RDS Data API を使用してSQLクエリを実行する

    Args:
        credentials (dict): データベース接続認証情報
        sql (str): 実行するSQLクエリ

    Returns:
        dict: クエリ実行結果

    Raises:
        Exception: クエリ実行に失敗した場合
    """
    try:
        logger.info("Executing Query via RDS Data API")
        logger.info(f"Query: {sql}")

        rds_data = boto3.client("rds-data")

        response = rds_data.execute_statement(
            resourceArn=credentials["cluster_arn"],
            secretArn=credentials["secret_arn"],
            database=credentials["database"],
            sql=sql,
        )
        del response["ResponseMetadata"]

        logger.info("Query executed successfully")
        logger.info(f"Query response: {response}")

        return response
    except Exception as e:
        logger.error(f"Failed to execute query: {str(e)}", exc_info=True)
        raise Exception(str(e))

def postgres_execute(sql):
    """
    Execute Query on the Aurora PostgreSQL database using Boto3 RDS Data API.

    This function retrieves database credentials from AWS Secrets Manager,
    then executes the provided Query against the database using the AWS RDS Data API.

    Args:
        sql (str): Query to execute on the PostgreSQL database.

    Returns:
        dict: Response from the RDS Data API containing query results.

    Raises:
        Exception: If there is an error retrieving credentials or executing the query.
    """
    try:
        logger.info("Starting SQL execution")
        credentials = get_db_credentials()
        logger.info("Executing Query")
        response = execute_query(credentials, sql)
        logger.info("SQL execution completed successfully")
        return response
    except Exception as e:
        logger.error(f"SQL execution failed: {str(e)}", exc_info=True)
        raise Exception(str(e))
