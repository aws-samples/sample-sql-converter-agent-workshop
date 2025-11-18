from time import sleep
from utils.logger import get_logger

logger = get_logger("callback_handler")


class AgentCallbackHandler:
    def __init__(self, avoid_throttling: bool = False):
        self.avoid_throttling = avoid_throttling

    def __call__(self, **kwargs):
        if "event" in kwargs:
            if "metadata" in kwargs["event"]:
                if "usage" in kwargs["event"]["metadata"]:
                    usage = kwargs["event"]["metadata"]["usage"]
                    total_tokens = usage.get("totalTokens", 0)
                    input_tokens = usage.get("inputTokens", 0)
                    output_tokens = usage.get("outputTokens", 0)
                    logger.info(
                        f"Token usage - Input: {input_tokens}, Output: {output_tokens}, Total: {total_tokens}"
                    )

                    if self.avoid_throttling:
                        sleep_time = (total_tokens / 8000) * 60
                        logger.info(f"Quota recovery sleep: {sleep_time} seconds")
                        sleep(sleep_time)
        elif "message" in kwargs:
            message = kwargs["message"]
            if message.get("role") == "user":
                for content in message.get("content", []):
                    if "toolResult" in content:
                        tool_result = content["toolResult"]
                        logger.info(
                            f"Tool result - ID: {tool_result.get('toolUseId')}, Status: {tool_result.get('status')}"
                        )
                        # ツール実行結果の内容も記録
                        result_content = tool_result.get("content", [])
                        if result_content:
                            for result_item in result_content:
                                if "text" in result_item:
                                    logger.info(
                                        f"Tool result content: {result_item['text']}"
                                    )
            elif message.get("role") == "assistant":
                for content in message.get("content", []):
                    if "toolUse" in content:
                        tool_use = content["toolUse"]
                        logger.info(
                            f"Tool executed: {tool_use.get('name')} with args: {tool_use.get('input', {})}"
                        )
                    elif "text" in content:
                        logger.info(f"AI response: {content['text']}")
        elif "data" in kwargs:
            logger.debug(f"Strands output: {kwargs['data']}")
