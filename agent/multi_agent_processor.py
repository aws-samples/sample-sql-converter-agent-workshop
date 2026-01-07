"""
マルチエージェント処理モジュール
3段階（Oracle検証→PostgreSQL変換→PostgreSQL検証）で変換を実行
"""
import os
from pathlib import Path

from multi_agent_config import MultiAgentPromptConfig


def load_prompt(prompt_path: str) -> str:
    """プロンプトファイルを読み込む"""
    module_dir = Path(__file__).parent
    full_path = module_dir / prompt_path
    with open(full_path, "r", encoding="utf-8") as f:
        return f.read()


def get_multi_agent_prompts(config: MultiAgentPromptConfig = None) -> dict:
    """各段階のシステムプロンプトを読み込む"""
    if config is None:
        config = MultiAgentPromptConfig()

    # 共通の変換ルールを読み込む
    conversion_rules = load_prompt(config.conversion_rules)

    # 出力仕様を読み込む
    output_specification = load_prompt(config.output_specification)

    # 変換プロンプトに変換ルールを埋め込む
    conversion_prompt = load_prompt(config.conversion)
    conversion_prompt = conversion_prompt.replace("{CONVERSION_RULES}", conversion_rules)

    # 検証プロンプトに出力仕様を埋め込む
    verification_prompt = load_prompt(config.verification)
    verification_prompt = verification_prompt.replace("{OUTPUT_SPECIFICATION}", output_specification)

    return {
        "oracle": load_prompt(config.oracle),
        "conversion": conversion_prompt,
        "verification": verification_prompt,
    }


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
    config: MultiAgentPromptConfig = None,
    avoid_throttling: bool = False,
    resumable_agent_run_func=None,
):
    """
    3段階マルチエージェント変換を実行

    Args:
        object_spec: オブジェクト指定（例: "procedure SCHEMA.PROC_NAME"）
        create_agent_func: エージェント作成関数（システムプロンプトを引数に取り、Agentを返す）
        mcp_client: MCPクライアント（コンテキストマネージャーとして使用）
        config: プロンプト設定（Noneの場合はデフォルト設定を使用）
        avoid_throttling: スロットリング対策を有効にするか
        resumable_agent_run_func: スロットリング対策用の再試行関数
    """
    prompts = get_multi_agent_prompts(config)
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
    print(f"\n{'='*60}")
    print(f"[Stage 1/3] Oracle検証: {object_spec}")
    print(f"{'='*60}")
    oracle_agent = create_agent_func(prompts["oracle"])
    run_agent(oracle_agent, oracle_message)

    # Stage 2: PostgreSQL変換
    print(f"\n{'='*60}")
    print(f"[Stage 2/3] PostgreSQL変換: {object_spec}")
    print(f"{'='*60}")
    conversion_agent = create_agent_func(prompts["conversion"])
    run_agent(conversion_agent, conversion_message)

    # Stage 3: PostgreSQL検証
    print(f"\n{'='*60}")
    print(f"[Stage 3/3] PostgreSQL検証: {object_spec}")
    print(f"{'='*60}")
    verification_agent = create_agent_func(prompts["verification"])
    run_agent(verification_agent, verification_message)

    print(f"\n{'='*60}")
    print(f"完了: {object_spec}")
    print(f"結果ディレクトリ: {result_dir}")
    print(f"{'='*60}")
