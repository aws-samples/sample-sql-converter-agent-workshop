"""
標準ライブラリのloggingを使用したロガー設定モジュール

このモジュールは、アプリケーション全体で一貫したログ設定を提供します。
独自実装を避け、Pythonの標準ライブラリのloggingモジュールを活用しています。
"""

import logging
import logging.config
import os
from datetime import datetime
from pathlib import Path


def setup_logger(name, log_dir='logs', log_level=logging.INFO):
    """
    標準ライブラリを使用したロガーのセットアップ
    
    Args:
        name (str): ロガーの名前（ログのプレフィックスとして使用）
        log_dir (str): ログファイルを保存するディレクトリ
        log_level (int): ログレベル（デフォルト: logging.INFO）
        
    Returns:
        logging.Logger: 設定済みのロガーインスタンス
    """
    # ログディレクトリの作成（pathlibを使用）
    log_path = Path(log_dir)
    log_path.mkdir(parents=True, exist_ok=True)
    
    # タイムスタンプベースのログファイル名を生成
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    log_file = log_path / f'{timestamp}.log'
    
    # logging.configを使用した設定
    config = {
        'version': 1,
        'disable_existing_loggers': False,
        'formatters': {
            'detailed': {
                'format': '[%(name)s] %(asctime)s - %(levelname)s - %(filename)s:%(lineno)d - %(funcName)s - %(message)s',
                'datefmt': '%Y-%m-%d %H:%M:%S'
            }
        },
        'handlers': {
            'file': {
                'class': 'logging.FileHandler',
                'filename': str(log_file),
                'formatter': 'detailed',
                'level': 'DEBUG',
                'encoding': 'utf-8'
            },
            'console': {
                'class': 'logging.StreamHandler',
                'formatter': 'detailed',
                'level': logging.getLevelName(log_level),
                'stream': 'ext://sys.stdout'
            }
        },
        'loggers': {
            name: {
                'level': logging.getLevelName(log_level),
                'handlers': ['file', 'console'],
                'propagate': False
            },
            'strands': {
                'level': logging.getLevelName(log_level),
                'handlers': ['file', 'console'],
                'propagate': False
            }
        }
    }
    
    # 設定を適用
    logging.config.dictConfig(config)
    
    # ロガーを取得して返す
    return logging.getLogger(name)
