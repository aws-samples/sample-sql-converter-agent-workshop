"""統合ログ設定モジュール - Strandsベストプラクティス準拠"""

import logging
from datetime import datetime
from pathlib import Path

def setup_application_logging(log_dir="logs", log_level=logging.DEBUG):
    """アプリケーション全体のログ設定を一度だけ実行"""
    
    log_path = Path(log_dir)
    log_path.mkdir(parents=True, exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = log_path / f"{timestamp}.log"
    
    # ルートロガー設定（すべてのログを統合）
    logging.basicConfig(
        level=log_level,
        format="[%(name)s] %(asctime)s - %(levelname)s - %(filename)s:%(lineno)d - %(funcName)s - %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        handlers=[
            logging.FileHandler(str(log_file), encoding="utf-8"),
            logging.StreamHandler()
        ],
        force=True
    )
    
    # 外部ライブラリのログレベルを調整
    logging.getLogger("botocore").setLevel(logging.WARNING)
    logging.getLogger("strands.telemetry.metrics").setLevel(logging.WARNING)
    logging.getLogger("strands").setLevel(log_level)
    
    return logging.getLogger("app")

def get_logger(name):
    """設定済み環境でロガーを取得"""
    return logging.getLogger(name)
