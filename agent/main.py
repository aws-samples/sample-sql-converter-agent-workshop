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
from utils.logger import setup_application_logging
from prompts.prompts import get_system_prompt

logger = setup_application_logging(log_level=logging.INFO)
os.environ["BYPASS_TOOL_CONSENT"] = "true"


def load_mcp_config():
    """MCP設定ファイルを読み込み"""
    with open("mcp.json", "r") as f:
        return json.load(f)


def create_bedrock_model():
    """BedrockModelを作成"""
    return BedrockModel(
        model_id="global.anthropic.claude-sonnet-4-5-20250929-v1:0",
        region_name="us-east-1",
        temperature=0,
        cache_tools="default",
        additional_request_fields={"anthropic_beta": ["context-1m-2025-08-07"]},
        boto_client_config=Config(
            retries={"total_max_attempts": 5, "mode": "standard"},
            connect_timeout=10,
            read_timeout=600,
        ),
    )


def create_mcp_client():
    """MCP クライアントを作成"""
    config = load_mcp_config()
    server_config = config["mcpServers"]["sql-converter"]

    return MCPClient(
        lambda: stdio_client(
            StdioServerParameters(
                command=server_config["command"],
                args=server_config["args"],
                env=server_config.get("env", {}),
            )
        )
    )


def create_agent(mode="db_object", system_prompt=None):
    """エージェントとMCPクライアントを初期化

    Args:
        mode: プロンプトモード（db_object, app, custom）
        system_prompt: 直接指定するシステムプロンプト（指定された場合はmodeを無視）
    """
    if system_prompt is None:
        system_prompt = get_system_prompt(mode)
    mcp_client = create_mcp_client()
    
    with mcp_client:
        mcp_tools = mcp_client.list_tools_sync()
        all_tools = [file_read, file_write] + mcp_tools

    agent = Agent(
        system_prompt=system_prompt,
        tools=all_tools,
        callback_handler=AgentCallbackHandler(),
        model=create_bedrock_model(),
    )

    return mcp_client, agent


def resumable_agent_run(
    mcp_client: MCPClient, agent: Agent, prompt: str, max_retry: int = 1000
) -> Agent:
    """エラー時の再試行機能付きエージェント実行"""
    last_user_content = prompt

    with mcp_client:
        for i in range(max_retry):
            try:
                agent(last_user_content)
                break
            except Exception as e:
                logger.error(f"エラーが発生しました (試行 {i + 1}/{max_retry}): {e}")

                if not agent.messages:
                    logger.warning(
                        "メッセージリストが空です。初期プロンプトで再試行します。"
                    )
                    last_user_content = prompt
                    gc.collect()
                    sleep(60)
                    continue

                # メッセージ履歴を調整して再試行
                for _ in range(2):
                    if len(agent.messages) == 0:
                        break
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
        "--mode",
        type=str,
        default="db_object",
        help="db_object or app or custom",
    )
    parser.add_argument(
        "--avoid-throttling",
        action="store_true",
        help="if true, it assumes severe token shortage environment",
    )
    parser.add_argument(
        "--multi-agent",
        action="store_true",
        help="Enable multi-agent 3-stage conversion (Oracle validation -> PostgreSQL conversion -> PostgreSQL verification)",
    )
    args = parser.parse_args()

    logger.info("Conversion start")

    if args.multi_agent:
        # マルチエージェント3段階変換モード
        from multi_agent_processor import run_multi_agent_conversion

        if not args.prompt:
            logger.error("--prompt is required with --multi-agent option")
            print("Error: --prompt is required with --multi-agent option")
            return

        user_input = args.prompt
        logger.info(f"Multi-agent conversion: {user_input}")

        # MCPクライアントを作成
        mcp_client = create_mcp_client()

        # エージェント作成関数（各段階のシステムプロンプトを受け取る）
        def create_agent_with_prompt(system_prompt):
            with mcp_client:
                mcp_tools = mcp_client.list_tools_sync()
                all_tools = [file_read, file_write] + mcp_tools

            return Agent(
                system_prompt=system_prompt,
                tools=all_tools,
                callback_handler=AgentCallbackHandler(avoid_throttling=args.avoid_throttling),
                model=create_bedrock_model(),
            )

        run_multi_agent_conversion(
            user_input,
            create_agent_with_prompt,
            mcp_client,
            avoid_throttling=args.avoid_throttling,
            resumable_agent_run_func=resumable_agent_run if args.avoid_throttling else None,
        )
        logger.info("Multi-agent conversion completed")

    elif args.prompt:
        user_input = args.prompt
        logger.info(f"User prompt: {user_input}")
        mcp_client, agent = create_agent(args.mode)
        if args.avoid_throttling:
            response = resumable_agent_run(mcp_client, agent, user_input)
        else:
            with mcp_client:
                response = agent(user_input)
        logger.info(f"AI response: {str(response)}")
        print(f"\n回答: {response}\n")

    else:
        # 対話モード
        mcp_client, agent = create_agent(args.mode)

        with mcp_client:
            while True:
                try:
                    user_input = input("質問を入力してください: ").strip()
                    user_input = "".join(
                        char
                        for char in user_input
                        if ord(char) >= 32 or char in "\t\n\r"
                    )

                    if user_input.lower() in ["quit", "exit", "q"]:
                        logger.info("エージェントを終了します。")
                        break

                    if not user_input:
                        print("質問を入力してください。")
                        continue

                    logger.info(f"User input: {user_input}")
                    response = agent(user_input)
                    logger.info(f"AI response: {response}")
                    print(f"\n回答: {response}\n")
                    print("-" * 50)

                except KeyboardInterrupt:
                    logger.info("\n\nエージェントを終了します。")
                    break
                except Exception as e:
                    logger.error(f"Error processing request: {str(e)}", exc_info=True)

                    if "ThrottlingException" in str(e):
                        logger.error(
                            "Bedrock throttling detected - API rate limit exceeded"
                        )
                        logger.debug(
                            "Consider using --avoid-throttling option or waiting before retry"
                        )

                    logger.error(f"エラーが発生しました: {str(e)}")
                    logger.warning("再度お試しください。")


if __name__ == "__main__":
    try:
        main()
        logger.info("Application completed successfully")
    except Exception:
        logger.critical("Application failed", exc_info=True)
