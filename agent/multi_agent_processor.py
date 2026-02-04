"""
マルチエージェント処理モジュール
3段階（Oracle検証→PostgreSQL変換→PostgreSQL検証）で変換を実行
"""
import os

from prompts.prompts import MultiAgent
from utils.logger import get_logger

logger = get_logger(__name__)


def get_result_dir(object_spec: str, base_dir: str = "./result") -> str:
    """オブジェクト名から結果ディレクトリパスを取得

    Args:
        object_spec: オブジェクト指定（例: "procedure SCHEMA.PROC_NAME"）
        base_dir: 結果保存ベースディレクトリ

    Returns:
        結果ディレクトリパス（例: "./result/PROC_NAME"）
    """
    parts = object_spec.strip().split()
    if len(parts) >= 2:
        full_name = parts[1]
        if "." in full_name:
            name_parts = full_name.split(".")
            # スキーマ名を除いた部分を使用
            result_dir_name = (
                ".".join(name_parts[1:]) if len(name_parts) >= 2 else name_parts[-1]
            )
        else:
            result_dir_name = full_name
    else:
        result_dir_name = object_spec.strip()
    return os.path.join(base_dir, result_dir_name)


def run_multi_agent_conversion(
    object_spec: str,
    create_agent_func,
    mcp_client,
    avoid_throttling: bool = False,
    resumable_agent_run_func=None,
):
    """
    3段階マルチエージェント変換を実行

    Args:
        object_spec: オブジェクト指定（例: "procedure SCHEMA.PROC_NAME"）
        create_agent_func: エージェント作成関数（システムプロンプトを引数に取り、Agentを返す）
        mcp_client: MCPクライアント（コンテキストマネージャーとして使用）
        avoid_throttling: スロットリング対策を有効にするか
        resumable_agent_run_func: スロットリング対策用の再試行関数
    """
    prompts = MultiAgent().get_prompts()
    result_dir = get_result_dir(object_spec)
    os.makedirs(result_dir, exist_ok=True)

    # メッセージテンプレート
    oracle_message = f"対象オブジェクト: {object_spec}\n結果保存先: {result_dir}/"
    conversion_message = f"対象オブジェクト: {object_spec}\nOracle DDL参照先: {result_dir}/oracle.sql\n結果保存先: {result_dir}/"
    verification_message = f"対象オブジェクト: {object_spec}\nOracle検証結果: {result_dir}/oracle_test.sql, {result_dir}/oracle_test.txt\nPostgreSQL変換結果: {result_dir}/postgres.sql\n結果保存先: {result_dir}/"

    # エージェント実行関数（スロットリング対策の有無で切り替え）
    def run_agent(agent, message):
        if avoid_throttling and resumable_agent_run_func:
            resumable_agent_run_func(mcp_client, agent, message)
        else:
            with mcp_client:
                agent(message)

    # Stage 1: Oracle検証
    logger.info(f"[Stage 1/3] Oracle検証開始: {object_spec}")
    oracle_agent = create_agent_func(prompts["oracle"])
    run_agent(oracle_agent, oracle_message)
    logger.info(f"[Stage 1/3] Oracle検証完了: {object_spec}")

    # Stage 2: PostgreSQL変換
    logger.info(f"[Stage 2/3] PostgreSQL変換開始: {object_spec}")
    conversion_agent = create_agent_func(prompts["conversion"])
    run_agent(conversion_agent, conversion_message)
    logger.info(f"[Stage 2/3] PostgreSQL変換完了: {object_spec}")

    # Stage 3: PostgreSQL検証
    logger.info(f"[Stage 3/3] PostgreSQL検証開始: {object_spec}")
    verification_agent = create_agent_func(prompts["verification"])
    run_agent(verification_agent, verification_message)
    logger.info(f"[Stage 3/3] PostgreSQL検証完了: {object_spec}")

    logger.info(f"マルチエージェント変換完了: {object_spec}, 結果ディレクトリ: {result_dir}")
