import argparse
import gc
import json
import logging
import os
from pathlib import Path
from time import sleep

from botocore.config import Config
from mcp import StdioServerParameters
from mcp.client.stdio import stdio_client
from strands import Agent
from strands.models import BedrockModel
from strands.tools.mcp import MCPClient
from strands_tools import file_read, file_write
from utils.callbacks import AgentCallbackHandler
from utils.logger import setup_logger

logger = setup_logger("app", log_level=logging.DEBUG)

# Strandsとbotocoreの詳細ログを有効化
logging.getLogger("strands").setLevel(logging.DEBUG)
logging.getLogger("botocore").setLevel(logging.DEBUG)
logging.getLogger("boto3").setLevel(logging.DEBUG)
os.environ["BYPASS_TOOL_CONSENT"] = "true"


def load_mcp_config():
    """mcp.json を読み込む"""
    with open("mcp.json", "r") as f:
        return json.load(f)


def create_mcp_client():
    """MCP クライアントを作成"""
    config = load_mcp_config()
    server_config = config["mcpServers"]["sql-converter"]
    
    return MCPClient(
        lambda: stdio_client(
            StdioServerParameters(
                command=server_config["command"],
                args=server_config["args"],
                env=server_config.get("env", {})
            )
        )
    )


def create_agent(system_prompt_file="./system_prompt.txt"):
    prompt_dir = Path(__file__).parent / "prompts"
    with open(prompt_dir / system_prompt_file, "rt") as f:
        system_prompt = f.read()

    # MCP クライアントを作成
    mcp_client = create_mcp_client()
    
    # MCPクライアントのコンテキスト内でツールを取得
    with mcp_client:
        mcp_tools = mcp_client.list_tools_sync()
        
        # file_read, file_writeを追加
        all_tools = [file_read, file_write] + mcp_tools

        # エージェントの初期化
        agent = Agent(
            system_prompt=system_prompt,
            tools=all_tools,
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
        
        return mcp_client, agent


def resumable_agent_run(mcp_client: MCPClient, agent: Agent, prompt: str, max_retry: int = 1000) -> Agent:
    last_user_content = prompt

    with mcp_client:
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
        mcp_client, agent = create_agent(args.system_prompt)
        if args.avoid_throttling:
            response = resumable_agent_run(mcp_client, agent, user_input)
        else:
            with mcp_client:
                response = agent(user_input)
        print(f"\n回答: {response}\n")

    else:
        # エージェントを一度だけ作成して会話を継続
        mcp_client, agent = create_agent(args.system_prompt)

        with mcp_client:
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
                    logger.debug(f"Exception type: {type(e).__name__}")
                    logger.debug(f"Exception args: {e.args}")
                    
                    # Throttling例外の詳細情報
                    if "ThrottlingException" in str(e):
                        logger.error("Bedrock throttling detected - API rate limit exceeded")
                        logger.debug("Consider using --avoid-throttling option or waiting before retry")
                    
                    logger.error(f"エラーが発生しました: {str(e)}")
                    logger.warning("再度お試しください。")


if __name__ == "__main__":
    try:
        main()
        logger.info("Application completed successfully")
    except Exception:
        logger.critical("Application failed", exc_info=True)
