import argparse
import gc
import logging
import os
from pathlib import Path
from time import sleep

from botocore.config import Config
from strands import Agent
from strands.models import BedrockModel
from strands_tools import file_read, file_write
from tools import run_ora_sql, run_pg_sql, shell
from utils.callbacks import AgentCallbackHandler
from utils.logger import setup_logger

logger = setup_logger("app", log_level=logging.INFO)
os.environ["BYPASS_TOOL_CONSENT"] = "true"


def create_agent(system_prompt_file="./system_prompt.txt"):
    prompt_dir = Path(__file__).parent / "prompts"
    with open(prompt_dir / system_prompt_file, "rt") as f:
        system_prompt = f.read()

    # エージェントの初期化
    return Agent(
        system_prompt=system_prompt,
        tools=[run_pg_sql, run_ora_sql, file_read, file_write, shell],
        callback_handler=AgentCallbackHandler(),
        model=BedrockModel(
            model_id="us.anthropic.claude-sonnet-4-20250514-v1:0",
            # model_id="anthropic.claude-sonnet-4-20250514-v1:0",
            region_name="us-east-1",
            temperature=0,
            top_p=0,
            cache_tools="default",
            additional_request_fields={"anthropic_beta": ["context-1m-2025-08-07"]},
            boto_client_config=Config(
                retries={"total_max_attempts": 5, "mode": "standard"},
                connect_timeout=10,
                read_timeout=600,
            ),
        ),
    )


def resumable_agent_run(agent: Agent, prompt: str, max_retry: int = 1000) -> Agent:
    last_user_content = prompt

    for i in range(max_retry):
        try:
            agent(last_user_content)
            break
        except Exception as e:
            logger.error(f"エラーが発生しました (試行 {i + 1}/{max_retry}): {e}")
            for _ in range(2):
                if agent.messages[-1].get("role") == "assistant":
                    del agent.messages[-1]
                elif agent.messages[-1].get("role") == "user":
                    last_user_content = agent.messages.pop().get("content", prompt)
                    break
                else:
                    logger.error("Detect undefined role")
                    raise e
            gc.collect()
            sleep(60)
    return agent


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--prompt", type=str, help="Prompt text")
    parser.add_argument(
        "--system-prompt",
        type=str,
        default="./system_prompt.txt",
        help="System prompt text file path from ./prompts",
    )
    parser.add_argument(
        "--avoid-throttling",
        action="store_true",
        help="if true, it assumes severe token shortage environment",
    )
    args = parser.parse_args()

    logger.info("Conversion start")

    if args.prompt:
        user_input = args.prompt
        agent = create_agent(args.system_prompt)
        if args.avoid_throttling:
            response = resumable_agent_run(agent, user_input)
        else:
            response = agent(user_input)
        print(f"\n回答: {response}\n")

    else:
        # エージェントを一度だけ作成して会話を継続
        agent = create_agent(args.system_prompt)

        while True:
            try:
                user_input = input("質問を入力してください: ").strip()
                # ターミナル制御文字を除去
                user_input = "".join(
                    char for char in user_input if ord(char) >= 32 or char in "\t\n\r"
                )

                if user_input.lower() in ["quit", "exit", "q"]:
                    logger.info("エージェントを終了します。")
                    break

                if not user_input:
                    print("質問を入力してください。")
                    continue

                logger.info(f"Processing request: {user_input}")

                logger.info("処理中...")

                response = agent(user_input)

                print(f"\n回答: {response}\n")
                print("-" * 50)

                logger.info("Request processed successfully")

            except KeyboardInterrupt:
                logger.info("\n\nエージェントを終了します。")
                break
            except Exception as e:
                logger.error(f"Error processing request: {str(e)}", exc_info=True)
                logger.error(f"エラーが発生しました: {str(e)}")
                logger.warning("再度お試しください。")


if __name__ == "__main__":
    try:
        main()
        logger.info("Application completed successfully")
    except Exception:
        logger.critical("Application failed", exc_info=True)
