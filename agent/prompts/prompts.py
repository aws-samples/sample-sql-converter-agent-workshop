import os

module_dir = os.path.dirname(os.path.abspath(__file__))
common_dir = os.path.join(module_dir, "./common")
db_object_dir = os.path.join(module_dir, "./db_object")
multi_agent_dir = os.path.join(db_object_dir, "multi_agent")
app_dir = os.path.join(module_dir, "./app")
custom_dir = os.path.join(module_dir, "./custom")


def load_file(dir, filename) -> str:
    with open(os.path.join(dir, filename), "rt") as f:
        return f.read()


class DBObject:
    def __init__(self):
        self.instruction = load_file(db_object_dir, "instruction.txt")
        self.workflow = load_file(db_object_dir, "workflow.txt")
        self.conversion_rules = load_file(common_dir, "conversion_rules.txt")
        self.test_strategy = load_file(db_object_dir, "test_strategy.txt")
        self.error_policy = load_file(db_object_dir, "error_policy.txt")
        self.output_specification = load_file(db_object_dir, "output_specification.txt")
        self.prompt = self.create_system_prompt()

    def create_system_prompt(self) -> str:
        prompt = f"""
{self.instruction}
{self.workflow}
{self.conversion_rules}
{self.test_strategy}
{self.error_policy}
{self.output_specification}
"""
        return prompt


class App:
    def __init__(self):
        self.instruction = load_file(app_dir, "instruction.txt")
        self.workflow = load_file(app_dir, "workflow.txt")
        self.general_rule = load_file(app_dir, "general_rule.txt")
        self.conversion_rules = load_file(common_dir, "conversion_rules.txt")
        self.prompt = self.create_system_prompt()

    def create_system_prompt(self) -> str:
        prompt = f"""
{self.instruction}
{self.workflow}
{self.general_rule}
{self.conversion_rules}
"""
        return prompt


class Custom:
    def __init__(self):
        self.prompt = load_file(custom_dir, "custom.txt")


class MultiAgent:
    """マルチエージェント用プロンプト管理（db_object向け3段階変換）"""

    def __init__(self):
        # 共通ファイル（db_object/commonと共有）
        self.conversion_rules = load_file(common_dir, "conversion_rules.txt")
        self.output_specification = load_file(db_object_dir, "output_specification.txt")
        self.test_strategy = load_file(db_object_dir, "test_strategy.txt")
        self.error_policy = load_file(db_object_dir, "error_policy.txt")

        # multi-agent専用プロンプト
        self.oracle = load_file(multi_agent_dir, "oracle_validation.txt")
        self.conversion = load_file(multi_agent_dir, "postgresql_conversion.txt")
        self.verification = load_file(multi_agent_dir, "postgresql_verification.txt")

    def get_prompts(self) -> dict:
        """各段階のシステムプロンプトを取得"""
        oracle_prompt = self.oracle.replace("{TEST_STRATEGY}", self.test_strategy)
        conversion_prompt = self.conversion.replace(
            "{CONVERSION_RULES}", self.conversion_rules
        )
        verification_prompt = self.verification.replace(
            "{OUTPUT_SPECIFICATION}", self.output_specification
        ).replace("{ERROR_POLICY}", self.error_policy)
        return {
            "oracle": oracle_prompt,
            "conversion": conversion_prompt,
            "verification": verification_prompt,
        }


def get_system_prompt(use_case):
    prompt = ""
    if use_case == "db_object":
        prompt = DBObject().prompt
    elif use_case == "app":
        prompt = App().prompt
    elif use_case == "custom":
        prompt = Custom().prompt
    return prompt
