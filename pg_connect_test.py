#!/usr/bin/env python3
"""
PostgreSQL 接続テストスクリプト
AWS Secrets Manager から接続情報を取得し、Aurora PostgreSQL に直接接続します
"""

import json
import sys
from datetime import datetime

import boto3
import psycopg
from colorama import Fore, Style, init

# カラー出力の初期化
init(autoreset=True)


def print_header(title):
    """ヘッダーを表示する関数"""
    width = 60
    print(f"\n{Fore.CYAN}{Style.BRIGHT}" + "=" * width)
    print(f"{title:^{width}}")
    print("=" * width + f"{Style.RESET_ALL}")


def print_success(message):
    """成功メッセージを表示する関数"""
    print(f"{Fore.GREEN}✓ {message}{Style.RESET_ALL}")


def print_error(message):
    """エラーメッセージを表示する関数"""
    print(f"{Fore.RED}✗ {message}{Style.RESET_ALL}")


def print_info(label, value):
    """情報を表示する関数"""
    print(f"{Fore.BLUE}• {label}:{Style.RESET_ALL} {value}")


def get_db_credentials():
    """データベース接続情報を取得する関数"""
    try:
        print_info("認証情報", "AWS Secrets Manager から取得中...")
        secrets_client = boto3.client("secretsmanager")
        secret_response = secrets_client.get_secret_value(
            SecretId="aurora-pg-credentials"
        )

        secret = json.loads(secret_response["SecretString"])

        print_success("認証情報の取得に成功しました")
        return {
            "host": secret["host"],
            "port": int(secret.get("port", 5432)),
            "user": secret["username"],
            "password": secret["password"],
            "dbname": "postgres",
        }
    except Exception as e:
        print_error("認証情報の取得に失敗しました")
        raise Exception(f"認証情報の取得エラー: {str(e)}")


def execute_query(credentials):
    """SQLクエリを実行する関数"""
    try:
        print_info("データベース", f"PostgreSQL（{credentials['host']}）に接続中...")
        with psycopg.connect(
            **credentials, sslmode="require", connect_timeout=10
        ) as conn:
            # 現在時刻とバージョンを取得するクエリ
            timestamp, version = conn.execute("SELECT NOW(), version();").fetchone()

        print_success("PostgreSQL への接続に成功しました")
        print_info("データベース時刻", timestamp)
        print_info("PostgreSQL バージョン", version)

        return True
    except Exception as e:
        print_error("PostgreSQL への接続に失敗しました")
        print_error(f"エラー詳細: {str(e)}")
        return False


def main():
    """メイン関数"""
    print_header("PostgreSQL 接続テスト")
    start_time = datetime.now()

    try:
        credentials = get_db_credentials()
        success = execute_query(credentials)

        end_time = datetime.now()
        duration = (end_time - start_time).total_seconds()

        print(f"\n{Fore.BLUE}実行時間: {duration:.2f} 秒{Style.RESET_ALL}")

        if success:
            print(f"\n{Fore.GREEN}{Style.BRIGHT}テスト結果: 成功 ✓{Style.RESET_ALL}")
            return 0
        else:
            print(f"\n{Fore.RED}{Style.BRIGHT}テスト結果: 失敗 ✗{Style.RESET_ALL}")
            return 1
    except Exception as e:
        print_error(f"予期せぬエラーが発生しました: {str(e)}")
        print(f"\n{Fore.RED}{Style.BRIGHT}テスト結果: 失敗 ✗{Style.RESET_ALL}")
        return 2


if __name__ == "__main__":
    sys.exit(main())
