# TODO: This is not working, need to check

from pathlib import Path
from litellm.integrations.custom_logger import CustomLogger

PROMPT_DIR = Path("/app/prompts")

PROMPT_FILES = {
    "gpt-oss:20b_local": "SYSTEM_PROMPTS.txt",
}

def load_prompt(model: str) -> str:
    filename = PROMPT_FILES.get(model)
    if not filename:
        return ""
    try:
        return (PROMPT_DIR / filename).read_text(encoding="utf-8").strip()
    except FileNotFoundError:
        return ""

class SystemPromptInjector(CustomLogger):
    async def async_pre_call_hook(self, user_api_key_dict, cache, data, call_type):
        if call_type not in ("completion", "acompletion"):
            return data
        prompt = load_prompt(data.get("model"))
        if prompt:
            data["messages"] = [{"role": "system", "content": prompt}] + data.get("messages", [])
            data.get("model")
        return data

proxy_handler_instance = SystemPromptInjector()
