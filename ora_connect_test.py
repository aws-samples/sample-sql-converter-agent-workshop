#!/usr/bin/env python3
"""
Oracle DB 接続テストスクリプト
AWS Secrets Manager から認証情報を取得し、Oracle Database に接続します
"""
import oracledb
import boto3
import json
import sys
from datetime import datetime
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
    """データベース認証情報を取得する関数"""
    try:
        print_info("認証情報", "AWS Secrets Manager から取得中...")
        secret_manager = boto3.client('secretsmanager')
        secret_response = secret_manager.get_secret_value(SecretId='oracle-credentials')
        secret = json.loads(secret_response["SecretString"])
        
        # IPアドレスの取得
        with open('./cdk/output.json', 'r') as f:
            ipaddress = json.load(f)["AuroraOracleStack"]["OracleInstancePublicIP"]
        
        print_success("認証情報の取得に成功しました")
        return {
            'username': secret["username"],
            'password': secret["password"],
            'ipaddress': ipaddress
        }
    except Exception as e:
        print_error(f"認証情報の取得に失敗しました")
        raise Exception(f"認証情報の取得エラー: {str(e)}")

def execute_query(credentials):
    """SQLクエリを実行する関数"""
    try:
        print_info("データベース", "Oracle DB に接続中...")
        connection = oracledb.connect(
            user=credentials['username'], 
            password=credentials['password'], 
            dsn=f"{credentials['ipaddress']}/XE"
        )
        
        cursor = connection.cursor()
        
        # 現在時刻を取得するクエリ
        cursor.execute("SELECT sysdate, banner FROM v$version WHERE banner LIKE 'Oracle%'")
        result = cursor.fetchone()
        timestamp = result[0]
        version = result[1]
        
        print_success("Oracle DB への接続に成功しました")
        print_info("データベース時刻", timestamp)
        print_info("Oracle バージョン", version)
        
        cursor.close()
        connection.close()
        return True
    except Exception as e:
        print_error(f"Oracle DB への接続に失敗しました")
        print_error(f"エラー詳細: {str(e)}")
        return False

def main():
    """メイン関数"""
    print_header("Oracle DB 接続テスト")
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
