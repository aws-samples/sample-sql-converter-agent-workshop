import argparse
import asyncio
import gc
import json
import logging
import os
import subprocess
from pathlib import Path
from time import sleep

from botocore.config import Config
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client
from strands import Agent
from strands.models import BedrockModel
from strands_tools import file_read, file_write
from utils.callbacks import AgentCallbackHandler
from utils.logger import setup_logger

logger = setup_logger("app", log_level=logging.INFO)
os.environ["BYPASS_TOOL_CONSENT"] = "true"


def load_mcp_config():
    """mcp.json を読み込む"""
    with open("mcp.json", "r") as f:
        return json.load(f)


async def get_mcp_tools_async():
    """MCP サーバーからツールを取得"""
    config = load_mcp_config()
    server_config = config["mcpServers"]["sql-converter"]
    
    server_params = StdioServerParameters(
        command=server_config["command"],
        args=server_config["args"],
        env=server_config.get("env", {})
    )
    
    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()
            
            # ツール一覧を取得
            tools_result = await session.list_tools()
            
            # MCP ツールをstrands用の関数に変換
            mcp_tools = []
            
            for tool in tools_result.tools:
                def create_tool_func(tool_name, tool_description):
                    def tool_func(*args, **kwargs):
                        # 引数を適切に処理
                        if args and not kwargs:
                            # 位置引数の場合、スキーマから推測
                            if tool_name == "run_ora_sql" and len(args) == 1:
                                kwargs = {"sql": args[0]}
                            elif tool_name == "run_postgres_sql" and len(args) == 1:
                                kwargs = {"sql": args[0]}
                            elif tool_name == "shell" and len(args) == 1:
                                kwargs = {"command": args[0]}
                        
                        # 同期的にMCPツールを呼び出し
                        async def call_mcp():
                            async with stdio_client(server_params) as (read, write):
                                async with ClientSession(read, write) as session:
                                    await session.initialize()
                                    result = await session.call_tool(tool_name, kwargs)
                                    return result.content[0].text if result.content else ""
                        
                        return asyncio.run(call_mcp())
                    
                    # strandsが認識できるように属性を設定
                    tool_func.__name__ = tool_name
                    tool_func.__doc__ = tool_description
                    return tool_func
                
                mcp_tools.append(create_tool_func(tool.name, tool.description))
            
            return mcp_tools


def get_mcp_tools():
    """MCP ツールを同期的に取得"""
    try:
        return asyncio.run(get_mcp_tools_async())
    except Exception as e:
        logger.warning(f"MCP ツール取得に失敗、フォールバック: {e}")
        # フォールバック: 既存ツールを使用
        from tools import run_ora_sql, run_pg_sql, shell
        return [run_pg_sql, run_ora_sql, shell]


def create_agent(system_prompt_file="./system_prompt.txt"):
    prompt_dir = Path(__file__).parent / "prompts"
    with open(prompt_dir / system_prompt_file, "rt") as f:
        system_prompt = f.read()

    # MCP ツールを取得
    mcp_tools = get_mcp_tools()
    
    # file_read, file_writeを追加
    all_tools = [file_read, file_write] + mcp_tools

    # エージェントの初期化
    return Agent(
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
