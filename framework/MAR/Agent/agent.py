from typing import Dict
import json
from loguru import logger

from MAR.Agent.agent_registry import AgentRegistry
from MAR.LLM.llm_registry import LLMRegistry
from MAR.Roles.role_registry import RoleRegistry
from MAR.Graph.node import Node
from MAR.Prompts.message_aggregation_plc import message_aggregation #,inner_test
from MAR.Prompts.post_process_plc import post_process, _extract_st_code, _format_codesys_errors, _build_rename_hint
from MAR.Prompts.output_format_plc import output_format_prompt
from MAR.Prompts.reasoning import reasoning_prompt
from MAR.Utils.ablation_config import get_ablation_mode


@AgentRegistry.register('Agent')
class Agent(Node):
    def __init__(self, id: str | None =None, domain: str = "", role:str = None , llm_name: str = "",reason_name: str = "",):
        super().__init__(id, reason_name, domain, llm_name)
        self.llm = LLMRegistry.get(llm_name)
        self.role = RoleRegistry(domain, role)
        self.reason = reason_name

        self.message_aggregation = self.role.get_message_aggregation()
        self.description = self.role.get_description()
        self.output_format = self.role.get_output_format()
        self.post_process = self.role.get_post_process()
        self.post_description = self.role.get_post_description()
        self.post_output_format = self.role.get_post_output_format()
        # Reflect
        if reason_name == "Reflection" and self.post_output_format == "None":
            self.post_output_format = self.output_format
            self.post_description = "\nReflect on possible errors in the answer above and answer again using the same format. If you think there are no errors in your previous answers that will affect the results, there is no need to correct them.\n"
    
    def _process_inputs(self, raw_inputs:Dict[str,str], spatial_info:Dict[str, Dict], temporal_info:Dict[str, Dict], **kwargs):
        query = raw_inputs['query']
        spatial_prompt = message_aggregation(raw_inputs, spatial_info, self.message_aggregation)
        temporal_prompt = message_aggregation(raw_inputs, temporal_info, self.message_aggregation)
        format_prompt = output_format_prompt[self.output_format]
        reason_prompt = reasoning_prompt[self.reason]

        system_prompt = f"{self.description}\n{reason_prompt}"
        system_prompt += f"\nFormat requirements that must be followed:\n{format_prompt}" if format_prompt else ""
        user_prompt = f"{query}\n"
        user_prompt += f"At the same time, other agents' outputs are as follows:\n\n{spatial_prompt}" if spatial_prompt else ""
        user_prompt += f"\n\nIn the last round of dialogue, other agents' outputs were:\n\n{temporal_prompt}" if temporal_prompt else ""
        return [{'role':'system','content':system_prompt},{'role':'user','content':user_prompt}]

    def _execute(self, input:Dict[str,str],  spatial_info:Dict[str,Dict], temporal_info:Dict[str,Dict],**kwargs):
        """
        Run the agent.
        Args:
            inputs: dict[str, str]: Raw inputs.
            spatial_info: dict[str, dict]: Spatial information.
            temporal_info: dict[str, dict]: Temporal information.
        Returns:
            Any: str: Aggregated message.
        """
        query = input['query']
        # passed, response= inner_test(input, spatial_info, temporal_info)
        # if passed:
        #     return response
        # prompt = self._process_inputs(input, spatial_info, temporal_info, **kwargs)
        # response = self.llm.gen(prompt)
        prompt = self._process_inputs(input, spatial_info, temporal_info, **kwargs)
        # --- Start of Modification ---
        response = None  # 1. 初始化 response 变量
        try:
            response = self.llm.gen(prompt)
            # 2. 检查 LLM 是否返回了空内容
            if not response:
                logger.error(f"Agent {self.id} (Role: {self.role.role}) received an empty or invalid response from the LLM.")
                return "" # 返回空字符串，避免程序崩溃
        except Exception as e:
            # 3. 捕获 API 调用过程中的任何异常
            logger.error(f"Agent {self.id} (Role: {self.role.role}) failed during LLM API call: {e}")
            return "" # 返回空字符串，避免程序崩溃
        # --- End of Modification --- 
        
        # --- 消融模式: 跳过 Agent 级别的后处理 ---
        if get_ablation_mode() == 'no_post_process':
            response, validation_info = response, {"passed": True, "errors": []}
        else:
            response, validation_info = post_process(input, response, self.post_process)

        # --- CODESYS 验证重试循环 ---
        if self.post_process == "CodesysSemanticCheck" and get_ablation_mode() != 'no_post_process':
            max_retries = 1  # 最多重试 1 次（即总共最多 2 次尝试）
            for attempt in range(max_retries):
                if validation_info.get("passed", False):
                    break

                logger.warning(f"Agent {self.id} (Role: {self.role.role}) CODESYS validation failed, retrying ({attempt+1}/{max_retries})...")

                # 构造修正 prompt：把 CODESYS 编译错误喂给 LLM
                error_details = validation_info.get("errors", [])
                error_text = ""
                for e in error_details:
                    desc = e.get("ErrorDesc", str(e))
                    error_text += f"  - {desc}\n"

                retry_system = (
                    f"{self.description}\n"
                    f"\nFix the ST code based on the CODESYS compilation errors below. "
                    f"Output corrected ST code in ```st ... ``` blocks."
                )
                retry_user = (
                    f"## Task\n{query}\n\n"
                    f"## CODESYS Compilation Errors to Fix\n{error_text}\n"
                    f"Please fix ALL compilation errors above and regenerate the correct ST code."
                )
                retry_prompt = [
                    {'role': 'system', 'content': retry_system},
                    {'role': 'user', 'content': retry_user}
                ]

                try:
                    response = self.llm.gen(retry_prompt)
                    if not response:
                        logger.error(f"Agent {self.id} retry returned empty response.")
                        continue
                except Exception as e:
                    logger.error(f"Agent {self.id} retry failed: {e}")
                    continue

                response, validation_info = post_process(input, response, self.post_process)

            if validation_info.get("passed", False):
                if validation_info.get("codesys_used", False):
                    logger.info(f"Agent {self.id} (Role: {self.role.role}) CODESYS validation passed.")
                else:
                    logger.info(f"Agent {self.id} (Role: {self.role.role}) ANTLR syntax check passed (CODESYS unavailable).")
            else:
                if validation_info.get("codesys_used", False):
                    logger.warning(f"Agent {self.id} (Role: {self.role.role}) CODESYS validation failed after all retries.")
                else:
                    logger.warning(f"Agent {self.id} (Role: {self.role.role}) ANTLR syntax check failed after all retries.")

        logger.debug(f"Agent {self.id} Role: {self.role.role} LLM: {self.llm.model_name}")
        logger.debug(f"system prompt:\n {prompt[0]['content']}")
        logger.debug(f"user prompt:\n {prompt[1]['content']}")
        logger.debug(f"response:\n {response}")

        post_format_prompt = output_format_prompt[self.post_output_format]
        if post_format_prompt is not None:
            system_prompt = f"{self.post_description}\n"
            system_prompt += f"Format requirements that must be followed:\n{post_format_prompt}"
            user_prompt = f"{query}\nThe initial thinking information is:\n{response} \n Please refer to the new format requirements when replying."
            prompt = [{'role':'system','content':system_prompt},{'role':'user','content':user_prompt}]
            response = self.llm.gen(prompt)
            logger.debug(f"post system prompt:\n {system_prompt}")
            logger.debug(f"post user prompt:\n {user_prompt}")
            logger.debug(f"post response:\n {response}")
            
            # #! 
            # received_id = []
            # role = self.role.role
            # received_id.append(self.id + '(' + role + ')')

            # entry = {
            #     "id": self.id,
            #     "role": self.role.role,
            #     "llm_name": self.llm.model_name,
            #     "system_prompt": prompt[0]['content'],
            #     "user_prompt": prompt[1]['content'],
            #     "received_id": received_id,
            #     "response": response,
            # }
            # try:
            #     with open(f'./result/tmp_log.json', 'r', encoding='utf-8') as f:
            #         data = json.load(f)
            # except (FileNotFoundError, json.JSONDecodeError):
            #     data = []

            # data.append(entry)

            # with open(f'./result/tmp_log.json', 'w', encoding='utf-8') as f:
            #     json.dump(data, f, ensure_ascii=False, indent=2)
            # #!
        return response
    
    def _async_execute(self, input, spatial_info, temporal_info, **kwargs):
        return self._execute(input, spatial_info, temporal_info, **kwargs)

@AgentRegistry.register('FinalRefer')
class FinalRefer(Node):
    def __init__(self, id: str | None =None, agent_name = "", domain = "", llm_name = "", prompt_file = ""):
        super().__init__(id, agent_name, domain, llm_name)
        self.llm = LLMRegistry.get(llm_name)
        self.prompt_file = json.load(open(f"{prompt_file}", 'r', encoding='utf-8'))
        # 消融指标追踪
        self.retry_count = 0
        self.first_pass_code = None

    def _process_inputs(self, raw_inputs, spatial_info, temporal_info, **kwargs):  
        system_prompt = f"{self.prompt_file['system']}"
        spatial_str = ""
        for id, info in spatial_info.items():
            spatial_str += id + ": " + info['output'] + "\n\n"
        user_prompt = f"The task is:\n\n {raw_inputs['query']}.\n At the same time, the output of other agents is as follows:\n\n{spatial_str} {self.prompt_file['user']}"
        return [{'role':'system','content':system_prompt},{'role':'user','content':user_prompt}]
    
    def _execute(self, input, spatial_info, temporal_info, **kwargs):
        prompt = self._process_inputs(input, spatial_info, temporal_info, **kwargs)
        response = self.llm.gen(prompt)
        logger.debug(f"Final Refer Node LLM: {self.llm.model_name}")
        logger.debug(f"Final System Prompt:\n {prompt[0]['content']}")
        logger.debug(f"Final User Prompt:\n {prompt[1]['content']}")
        logger.debug(f"Final Response:\n {response}")

        # 记录首次生成代码 (消融指标)
        first_code = _extract_st_code(response)
        self.first_pass_code = first_code
        self.retry_count = 0

        # --- CODESYS 编译验证 + 修正循环 ---
        if get_ablation_mode() in ('no_codesys_feedback', 'no_post_process'):
            logger.info(f"FinalNode: [Ablation:{get_ablation_mode()}] CODESYS feedback disabled, skipping internal compilation check")
            return response

        max_retries = 1
        for attempt in range(1, max_retries + 2):  # attempt 1 = first, 2+ = retries
            try:
                from MAR.Tools.PLC.codesys_client import get_codesys_client
                client = get_codesys_client()
                code = _extract_st_code(response)
                codesys_result = client.compile_code(code)
                codesys_passed = codesys_result.get("success", False)
            except Exception as e:
                logger.warning(f"FinalNode: CODESYS client error (attempt {attempt}): {e}")
                codesys_passed = False
                codesys_result = {"errors": [{"ErrorDesc": str(e)}]}

            if codesys_passed:
                logger.info(f"FinalNode: CODESYS compilation passed (attempt {attempt}).")
                return response

            error_count = len(codesys_result.get("errors", []))
            logger.warning(f"FinalNode: CODESYS compilation failed (attempt {attempt}/{max_retries + 1}), {error_count} error(s).")

            if attempt > max_retries:
                logger.warning(f"FinalNode: max retries ({max_retries + 1}) exhausted, returning last response.")
                return response

            # 构造修复 prompt
            error_text = ""
            for e in codesys_result.get("errors", []):
                error_text += f"  - {e.get('ErrorDesc', str(e))}\n"

            retry_system = (
                f"{self.prompt_file.get('system', '')}\n\n"
                f"Your previous ST code failed CODESYS compilation with the following errors.\n"
                f"Fix ALL of them and output the corrected ST code in ```st ... ``` blocks."
            )
            retry_user = (
                f"## Task\n{input.get('query', '')}\n\n"
                f"## CODESYS Compilation Errors to Fix\n{error_text}\n"
                f"Please fix ALL compilation errors above and regenerate the correct ST code."
            )
            retry_prompt = [
                {'role': 'system', 'content': retry_system},
                {'role': 'user', 'content': retry_user}
            ]

            self.retry_count += 1
            logger.debug(f"FinalNode retry {self.retry_count} response:\n{response}")
            try:
                response = self.llm.gen(retry_prompt)
                if not response:
                    logger.error("FinalNode retry returned empty response.")
                    return response
            except Exception as e:
                logger.error(f"FinalNode retry LLM call failed: {e}")
                return response

        return response
    
    def _async_execute(self, input, spatial_info, temporal_info, **kwargs):
        return self._execute(input, spatial_info, temporal_info, **kwargs)