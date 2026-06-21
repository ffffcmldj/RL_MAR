import aiohttp
from typing import List, Union, Optional
from tenacity import retry, wait_random_exponential, stop_after_attempt
from typing import Dict, Any
from dotenv import load_dotenv
import os
import requests
from groq import Groq, AsyncGroq
from openai import OpenAI, AsyncOpenAI

from MAR.LLM.price import cost_count
from MAR.LLM.llm import LLM
from MAR.LLM.llm_registry import LLMRegistry

load_dotenv()
MINE_BASE_URL = os.getenv('BASE_URL')
MINE_API_KEYS = os.getenv('API_KEY')


@LLMRegistry.register('ALLChat')
class ALLChat(LLM):
    def __init__(self, model_name: str):
        self.model_name = model_name
    
    @retry(wait=wait_random_exponential(max=180), stop=stop_after_attempt(5))
    def gen(
        self,
        messages: Union[List[Dict], str],
        max_tokens: Optional[int] = None,
        temperature: Optional[float] = None,
        num_comps: Optional[int] = None,
        ) -> Union[List[str], str]:
        if max_tokens is None:
            max_tokens = self.DEFAULT_MAX_TOKENS
        if temperature is None:
            temperature = self.DEFAULT_TEMPERATURE
        if num_comps is None:
            num_comps = self.DEFUALT_NUM_COMPLETIONS

        if isinstance(messages, str):
            messages = [{'role':"user", 'content':messages}]

        try:
            client = OpenAI(base_url = os.environ.get("URL"),
                            api_key = os.environ.get("KEY"),
                            timeout=180)
            chat_completion = client.chat.completions.create(
            messages = messages,
            model = self.model_name,
            max_tokens = max_tokens,
            temperature = temperature,
            )

            # Check if response is valid ChatCompletion object
            if hasattr(chat_completion, 'choices') and len(chat_completion.choices) > 0:
                response = chat_completion.choices[0].message.content
                # Validate response is not HTML
                if response and response.strip().startswith('<!doctype html>'):
                    raise ValueError(f"API returned HTML page instead of JSON response. This may indicate authentication issues or API endpoint problems.")
                # Token cost tracking (use actual token counts from API response)
                usage = getattr(chat_completion, 'usage', None)
                prompt = "".join([item['content'] for item in messages])
                cost_count(prompt, response, self.model_name, usage=usage)
                return response
            else:
                # Debug: print what we actually received
                print(f"DEBUG: Unexpected response type: {type(chat_completion)}")
                print(f"DEBUG: Response content: {str(chat_completion)[:200]}")
                raise ValueError(f"Unexpected response format: {type(chat_completion)}")

        except Exception as e:
            print(f"OpenAI API Error: {e}")
            print(f"Base URL: {os.environ.get('URL')}")
            print(f"Model: {self.model_name}")
            print(f"Messages length: {sum(len(m.get('content', '')) for m in messages)}")
            raise e

    async def agen(
        self,
        messages: Union[List[Dict], str],
        max_tokens: Optional[int] = None,
        temperature: Optional[float] = None,
        num_comps: Optional[int] = None,
        ) -> Union[List[str], str]:

        if max_tokens is None:
            max_tokens = self.DEFAULT_MAX_TOKENS
        if temperature is None:
            temperature = self.DEFAULT_TEMPERATURE
        if num_comps is None:
            num_comps = self.DEFUALT_NUM_COMPLETIONS

        if isinstance(messages, str):
            messages = [{'role':"user", 'content':messages}]
        
        client = AsyncOpenAI(base_url = os.environ.get("URL"),
                             api_key = os.environ.get("KEY"),
                             timeout = 600)
        chat_completion = await client.chat.completions.create(
        messages = messages,
        model = self.model_name,
        max_tokens = max_tokens,
        temperature = temperature,
        )
        response = chat_completion.choices[0].message.content

        return response
    

@LLMRegistry.register('Deepseek')
class DSChat(LLM):
    def __init__(self, model_name: str):
        self.model_name = model_name

    @retry(wait=wait_random_exponential(max=180), stop=stop_after_attempt(5))
    def gen(
        self,
        messages: Union[List[Dict], str],
        max_tokens: Optional[int] = None,
        temperature: Optional[float] = None,
        num_comps: Optional[int] = None,
        ) -> Union[List[str], str]:
        if max_tokens is None:
            max_tokens = self.DEFAULT_MAX_TOKENS
        if temperature is None:
            from MAR.Utils.ablation_config import get_ablation_temperature
            t = get_ablation_temperature()
            temperature = t if t is not None else self.DEFAULT_TEMPERATURE
        if num_comps is None:
            num_comps = self.DEFUALT_NUM_COMPLETIONS

        if isinstance(messages, str):
            messages = [{'role':"user", 'content':messages}]
        from MAR.Utils.ablation_config import get_ablation_frequency_penalty
        freq_penalty = get_ablation_frequency_penalty()
        client = OpenAI(base_url = os.environ.get("DS_URL"),
                        api_key = os.environ.get("DS_KEY"),
                        timeout=180)
        create_kwargs = dict(
            messages = messages,
            model = self.model_name,
            max_tokens = max_tokens,
            temperature = temperature,
        )
        if freq_penalty is not None:
            create_kwargs['frequency_penalty'] = freq_penalty
        chat_completion = client.chat.completions.create(**create_kwargs)
        response = chat_completion.choices[0].message.content
        usage = getattr(chat_completion, 'usage', None)
        prompt = "".join([item['content'] for item in messages])
        cost_count(prompt, response, self.model_name, usage=usage)
        return response

    async def agen(
        self,
        messages: Union[List[Dict], str],
        max_tokens: Optional[int] = None,
        temperature: Optional[float] = None,
        num_comps: Optional[int] = None,
        ) -> Union[List[str], str]:

        if max_tokens is None:
            max_tokens = self.DEFAULT_MAX_TOKENS
        if temperature is None:
            from MAR.Utils.ablation_config import get_ablation_temperature
            t = get_ablation_temperature()
            temperature = t if t is not None else self.DEFAULT_TEMPERATURE
        if num_comps is None:
            num_comps = self.DEFUALT_NUM_COMPLETIONS

        if isinstance(messages, str):
            messages = [{'role':"user", 'content':messages}]

        from MAR.Utils.ablation_config import get_ablation_frequency_penalty
        freq_penalty = get_ablation_frequency_penalty()
        client = AsyncOpenAI(base_url = os.environ.get("DS_URL"),
                             api_key = os.environ.get("DS_KEY"),)
        create_kwargs = dict(
            messages = messages,
            model = self.model_name,
            max_tokens = max_tokens,
            temperature = temperature,
        )
        if freq_penalty is not None:
            create_kwargs['frequency_penalty'] = freq_penalty
        chat_completion = await client.chat.completions.create(**create_kwargs)
        response = chat_completion.choices[0].message.content

        return response

@retry(wait=wait_random_exponential(max=100), stop=stop_after_attempt(10))
async def achat(
    model: str,
    msg: List[Dict],):
    request_url = MINE_BASE_URL
    authorization_key = MINE_API_KEYS
    headers = {
        'Content-Type': 'application/json',
        'authorization': authorization_key
    }
    data = {
        "name": model + '-y',
        "inputs": {
            "stream": False,
            "msg": repr(msg),
        }
    }
    async with aiohttp.ClientSession() as session:
        async with session.post(request_url, headers=headers ,json=data) as response:
            response_data = await response.json()
            if isinstance(response_data['data'],str):
                prompt = "".join([item['content'] for item in msg])
                cost_count(prompt,response_data['data'], model)
                return response_data['data']
            else:
                raise Exception("api error")

@retry(wait=wait_random_exponential(max=100), stop=stop_after_attempt(10))   
def chat(
    model: str,
    msg: List[Dict],):
    request_url = MINE_BASE_URL
    authorization_key = MINE_API_KEYS
    headers = {
        'Content-Type': 'application/json',
        'authorization': authorization_key
    }
    data = {
        "name": model+'-y',
        "inputs": {
            "stream": False,
            "msg": repr(msg),
        }
    }
    response = requests.post(request_url, headers=headers ,json=data)
    response_data = response.json()
    if isinstance(response_data['data'],str):
        prompt = "".join([item['content'] for item in msg])
        cost_count(prompt,response_data['data'], model)
        return response_data['data']
    else:
        raise Exception("api error")

@LLMRegistry.register('GPTChat')
class GPTChat(LLM):
    def __init__(self, model_name: str):
        self.model_name = model_name

    async def agen(
        self,
        messages: Union[List[Dict], str],
        max_tokens: Optional[int] = None,
        temperature: Optional[float] = None,
        num_comps: Optional[int] = None,
        ) -> Union[List[str], str]:

        if max_tokens is None:
            max_tokens = self.DEFAULT_MAX_TOKENS
        if temperature is None:
            temperature = self.DEFAULT_TEMPERATURE
        if num_comps is None:
            num_comps = self.DEFUALT_NUM_COMPLETIONS
        
        if isinstance(messages, str):
            messages = [{'role':"user", 'content':messages}]
        return await achat(self.model_name,messages)
    
    def gen(
        self,
        messages: Union[List[Dict], str],
        max_tokens: Optional[int] = None,
        temperature: Optional[float] = None,
        num_comps: Optional[int] = None,
        ) -> Union[List[str], str]:
        
        if max_tokens is None:
            max_tokens = self.DEFAULT_MAX_TOKENS
        if temperature is None:
            temperature = self.DEFAULT_TEMPERATURE
        if num_comps is None:
            num_comps = self.DEFUALT_NUM_COMPLETIONS

        if isinstance(messages, str):
            messages = [{'role':"user", 'content':messages}]
        return chat(self.model_name,messages)
    

@LLMRegistry.register('Groq')
class GroqChat(LLM):
    def __init__(self, model_name: str):
        self.model_name = model_name
    
    @retry(wait=wait_random_exponential(max=180), stop=stop_after_attempt(5))
    def gen(
        self,
        messages: Union[List[Dict], str],
        max_tokens: Optional[int] = None,
        temperature: Optional[float] = None,
        num_comps: Optional[int] = None,
        ) -> Union[List[str], str]:
        # TODO: Add num_comps to the request
        if max_tokens is None:
            max_tokens = self.DEFAULT_MAX_TOKENS
        if temperature is None:
            temperature = self.DEFAULT_TEMPERATURE
        if num_comps is None:
            num_comps = self.DEFUALT_NUM_COMPLETIONS

        if isinstance(messages, str):
            messages = [{'role':"user", 'content':messages}]
        
        client = Groq(api_key=os.environ.get("GROQ_API_KEY"),)
        chat_completion = client.chat.completions.create(
        messages = messages,
        model = self.model_name,
        )
        response = chat_completion.choices[0].message.content
        usage = getattr(chat_completion, 'usage', None)
        prompt = "".join([item['content'] for item in messages])
        cost_count(prompt, response, self.model_name, usage=usage)
        return response

    async def agen(
        self,
        messages: Union[List[Dict], str],
        max_tokens: Optional[int] = None,
        temperature: Optional[float] = None,
        num_comps: Optional[int] = None,
        ) -> Union[List[str], str]:
        # TODO: Add num_comps to the request
        if max_tokens is None:
            max_tokens = self.DEFAULT_MAX_TOKENS
        if temperature is None:
            temperature = self.DEFAULT_TEMPERATURE
        if num_comps is None:
            num_comps = self.DEFUALT_NUM_COMPLETIONS

        if isinstance(messages, str):
            messages = [{'role':"user", 'content':messages}]
        
        client = AsyncGroq(api_key=os.environ.get("GROQ_API_KEY"),)
        chat_completion = await client.chat.completions.create(
        messages = messages,
        model = self.model_name,
        max_tokens = max_tokens,
        temperature = temperature,
        )
        response = chat_completion.choices[0].message.content

        return response
    

@LLMRegistry.register('AIGBest')
class AIGBestChat(LLM):
    def __init__(self, model_name: str):
        self.model_name = model_name

    @retry(wait=wait_random_exponential(max=180), stop=stop_after_attempt(5))
    def gen(
        self,
        messages: Union[List[Dict], str],
        max_tokens: Optional[int] = None,
        temperature: Optional[float] = None,
        num_comps: Optional[int] = None,
    ) -> Union[List[str], str]:
        if max_tokens is None:
            max_tokens = self.DEFAULT_MAX_TOKENS
        if temperature is None:
            temperature = self.DEFAULT_TEMPERATURE
        if num_comps is None:
            num_comps = self.DEFUALT_NUM_COMPLETIONS

        if isinstance(messages, str):
            messages = [{'role': "user", 'content': messages}]

        try:
            api_key = os.environ.get("GPT4O_KEY") if "gpt-4o" in self.model_name and "mini" not in self.model_name else os.environ.get("GPT_KEY")
            client = OpenAI(base_url=os.environ.get("GPT_URL"),
                            api_key=api_key,
                            timeout=180)
            chat_completion = client.chat.completions.create(
                messages=messages,
                model=self.model_name,
                max_tokens=max_tokens,
                temperature=temperature,
            )

            if hasattr(chat_completion, 'choices') and len(chat_completion.choices) > 0:
                response = chat_completion.choices[0].message.content
                usage = getattr(chat_completion, 'usage', None)
                prompt = "".join([item['content'] for item in messages])
                cost_count(prompt, response, self.model_name, usage=usage)
                return response
            else:
                raise ValueError(f"Unexpected response format: {type(chat_completion)}")

        except Exception as e:
            print(f"AIGBest API Error: {e}")
            print(f"Base URL: {os.environ.get('GPT_URL')}")
            print(f"Model: {self.model_name}")
            raise e

    async def agen(
        self,
        messages: Union[List[Dict], str],
        max_tokens: Optional[int] = None,
        temperature: Optional[float] = None,
        num_comps: Optional[int] = None,
    ) -> Union[List[str], str]:
        if max_tokens is None:
            max_tokens = self.DEFAULT_MAX_TOKENS
        if temperature is None:
            temperature = self.DEFAULT_TEMPERATURE
        if num_comps is None:
            num_comps = self.DEFUALT_NUM_COMPLETIONS

        if isinstance(messages, str):
            messages = [{'role': "user", 'content': messages}]

        client = AsyncOpenAI(base_url=os.environ.get("GPT_URL"),
                             api_key=os.environ.get("GPT4O_KEY") if "gpt-4o" in self.model_name and "mini" not in self.model_name else os.environ.get("GPT_KEY"),
                             timeout=600)
        chat_completion = await client.chat.completions.create(
            messages=messages,
            model=self.model_name,
            max_tokens=max_tokens,
            temperature=temperature,
        )
        response = chat_completion.choices[0].message.content
        return response


@LLMRegistry.register('Qwen')
class QwenChat(LLM):
    def __init__(self, model_name: str):
        self.model_name = model_name

    @retry(wait=wait_random_exponential(max=180), stop=stop_after_attempt(5))
    def gen(
        self,
        messages: Union[List[Dict], str],
        max_tokens: Optional[int] = None,
        temperature: Optional[float] = None,
        num_comps: Optional[int] = None,
    ) -> Union[List[str], str]:
        if max_tokens is None:
            max_tokens = self.DEFAULT_MAX_TOKENS
        if temperature is None:
            temperature = self.DEFAULT_TEMPERATURE
        if num_comps is None:
            num_comps = self.DEFUALT_NUM_COMPLETIONS

        if isinstance(messages, str):
            messages = [{'role': 'user', 'content': messages}]

        try:
            client = OpenAI(base_url=os.environ.get("QWEN_URL"),
                            api_key=os.environ.get("QWEN_KEY"),
                            timeout=180)
            chat_completion = client.chat.completions.create(
                messages=messages,
                model=self.model_name,
                max_tokens=max_tokens,
                temperature=temperature,
            )

            if hasattr(chat_completion, 'choices') and len(chat_completion.choices) > 0:
                response = chat_completion.choices[0].message.content
                usage = getattr(chat_completion, 'usage', None)
                prompt = "".join([item['content'] for item in messages])
                cost_count(prompt, response, self.model_name, usage=usage)
                return response
            else:
                raise ValueError(f"Unexpected response format: {type(chat_completion)}")

        except Exception as e:
            print(f"Qwen API Error: {e}")
            print(f"Base URL: {os.environ.get('QWEN_URL')}")
            print(f"Model: {self.model_name}")
            raise e

    async def agen(
        self,
        messages: Union[List[Dict], str],
        max_tokens: Optional[int] = None,
        temperature: Optional[float] = None,
        num_comps: Optional[int] = None,
    ) -> Union[List[str], str]:
        if max_tokens is None:
            max_tokens = self.DEFAULT_MAX_TOKENS
        if temperature is None:
            temperature = self.DEFAULT_TEMPERATURE
        if num_comps is None:
            num_comps = self.DEFUALT_NUM_COMPLETIONS

        if isinstance(messages, str):
            messages = [{'role': 'user', 'content': messages}]

        client = AsyncOpenAI(base_url=os.environ.get("QWEN_URL"),
                             api_key=os.environ.get("QWEN_KEY"),
                             timeout=600)
        chat_completion = await client.chat.completions.create(
            messages=messages,
            model=self.model_name,
            max_tokens=max_tokens,
            temperature=temperature,
        )
        response = chat_completion.choices[0].message.content
        return response


@LLMRegistry.register('OpenRouter')
class OpenRouterChat(LLM):
    def __init__(self, model_name: str):
        self.model_name = model_name
    
    @retry(wait=wait_random_exponential(max=180), stop=stop_after_attempt(5))
    def gen(
        self,
        messages: Union[List[Dict], str],
        max_tokens: Optional[int] = None,
        temperature: Optional[float] = None,
        num_comps: Optional[int] = None,
        ) -> Union[List[str], str]:
        if max_tokens is None:
            max_tokens = self.DEFAULT_MAX_TOKENS
        if temperature is None:
            temperature = self.DEFAULT_TEMPERATURE
        if num_comps is None:
            num_comps = self.DEFUALT_NUM_COMPLETIONS

        if isinstance(messages, str):
            messages = [{'role':"user", 'content':messages}]
        client = OpenAI(base_url = os.environ.get("OPENROUTER_BASE_URL"),
                        api_key = os.environ.get("OPENROUTER_API_KEY"),
                        timeout=180)
        chat_completion = client.chat.completions.create(
        messages = messages,
        model = self.model_name,
        )
        response = chat_completion.choices[0].message.content
        return response

    async def agen(
        self,
        messages: Union[List[Dict], str],
        max_tokens: Optional[int] = None,
        temperature: Optional[float] = None,
        num_comps: Optional[int] = None,
        ) -> Union[List[str], str]:
        # TODO
        return 0