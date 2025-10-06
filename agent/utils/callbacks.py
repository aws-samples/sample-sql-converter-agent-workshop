from time import sleep

from utils.logger import setup_logger

logger = setup_logger("callback_handler")


class AgentCallbackHandler:
    def __init__(self, avoid_throttling: bool = False):
        self.avoid_throttling = avoid_throttling

    def __call__(self, **kwargs):
        if "event" in kwargs:
            if "metadata" in kwargs["event"]:
                if "usage" in kwargs["event"]["metadata"]:
                    if self.avoid_throttling:
                        usage = kwargs["event"]["metadata"]["usage"]
                        total_tokens = usage.get("totalTokens", 0)
                        input_tokens = usage.get("inputTokens", 0)
                        output_tokens = usage.get("outputTokens", 0)
                        sleep_time = (total_tokens / 8000) * 60
                        message = f"[AgentCallbackHandler] input token を {input_tokens}, output token を {output_tokens}, 合計 {total_tokens} 使用しました。Quota 回復のため {sleep_time} 秒休みます"
                        logger.info(message)
                        sleep(sleep_time)
        elif "data" in kwargs:
            logger.debug(f"Strands output: {kwargs['data']}")
        elif "current_tool_use" in kwargs:
            tool = kwargs["current_tool_use"]
            logger.debug(f"Strands using tool: {tool.get('name', 'unknown')}")
