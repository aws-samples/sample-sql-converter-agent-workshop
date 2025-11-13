import os

module_dir = os.path.dirname(os.path.abspath(__file__))
db_object_dir = os.path.join(module_dir, "./db_object")

def load_file(dir,filename)->str:
    with open(os.path.join(dir,filename),"rt") as f:
        return f.read()

class DBObject():
    def __init__(self):
        self.instruction = load_file(db_object_dir, "instruction.txt")
        self.workflow = load_file(db_object_dir, "workflow.txt")
        self.conversion_rules = load_file(module_dir,"conversion_rules.txt")
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

def get_system_prompt(use_case):
    prompt = ""
    if use_case == "DB_OBJECT":
        prompt = DBObject().prompt
    return prompt