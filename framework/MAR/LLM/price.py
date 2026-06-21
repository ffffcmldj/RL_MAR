from MAR.Utils.globals import Cost, PromptTokens, CompletionTokens

def cal_token(text: str) -> int:
    """Estimate token count (fallback when API usage data is unavailable)."""
    try:
        import tiktoken
        encoder = tiktoken.encoding_for_model('gpt-4o')
        return len(encoder.encode(text))
    except Exception:
        return int(len(text) * 0.6)


def cost_count(prompt, response, model_name, usage=None):
    prompt_len: int
    completion_len: int
    price: float

    if usage is not None:
        prompt_len = getattr(usage, 'prompt_tokens', 0) or 0
        completion_len = getattr(usage, 'completion_tokens', 0) or 0

        cached_tokens = 0
        prompt_details = getattr(usage, 'prompt_tokens_details', None)
        if prompt_details is not None:
            if hasattr(prompt_details, 'cached_tokens'):
                cached_tokens = prompt_details.cached_tokens or 0
            elif isinstance(prompt_details, dict):
                cached_tokens = prompt_details.get('cached_tokens', 0)
    else:
        prompt_len = cal_token(prompt or "")
        completion_len = cal_token(response or "")
        cached_tokens = 0

    if model_name not in MODEL_PRICE:
        return 0, 0, 0

    prices = MODEL_PRICE[model_name]
    uncached_input = max(0, prompt_len - cached_tokens)
    input_cost = uncached_input * prices['input'] / 1_000_000
    if cached_tokens > 0 and 'input_cached' in prices:
        input_cost += cached_tokens * prices['input_cached'] / 1_000_000
    else:
        input_cost += cached_tokens * prices['input'] / 1_000_000

    output_cost = completion_len * prices['output'] / 1_000_000
    price = input_cost + output_cost

    Cost.instance().add(price)
    PromptTokens.instance().add(prompt_len)
    CompletionTokens.instance().add(completion_len)

    return price, prompt_len, completion_len


MODEL_PRICE = {
    "gpt-4o": {
        "input": 2.5,
        "input_cached": 1.25,
        "output": 10.0,
        "currency": "USD",
    },
    "gpt-4o-mini": {
        "input": 0.15,
        "input_cached": 0.075,
        "output": 0.6,
        "currency": "USD",
    },
    "deepseek-ai/DeepSeek-V3.2": {
        "input": 2.0,
        "output": 3.0,
        "currency": "CNY",
    },
    "qwen3.5-9b": {
        "input": 0.5,
        "output": 4.0,
        "currency": "CNY",
    },
}


def get_currency(model_name: str) -> str:
    """Return the billing currency for the model, defaulting to 'USD'."""
    if model_name in MODEL_PRICE:
        return MODEL_PRICE[model_name].get('currency', 'USD')
    return 'USD'
