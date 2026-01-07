"""
マルチエージェント処理の設定
各エージェントのシステムプロンプトファイルパスを定義
"""
from dataclasses import dataclass


@dataclass
class MultiAgentPromptConfig:
    """各エージェントのシステムプロンプトファイル設定"""

    oracle: str = "prompts/multi_agent/oracle_validation.txt"
    conversion: str = "prompts/multi_agent/postgresql_conversion.txt"
    verification: str = "prompts/multi_agent/postgresql_verification.txt"
    conversion_rules: str = "prompts/common/conversion_rules.txt"
    output_specification: str = "prompts/db_object/output_specification.txt"
