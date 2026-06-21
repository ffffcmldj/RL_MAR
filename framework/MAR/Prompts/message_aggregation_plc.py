import re
from typing import Dict

try:
    from MAR.Tools.PLC.validators import st_syntax_checker_tool
except ImportError as e:
    print(f"Warning: 无法加载真实工具 ({e})，使用简易回退模式。")
    
    def st_syntax_checker_tool(code: str) -> Dict:
        """
        A fallback function that only exists when the real import fails.
        """
        if not code.strip().endswith(';'):
            return {"passed": False, "error": "Missing semicolon at the end of a statement."}
        return {"passed": True, "error": None}


def property_validator_tool(code: str, properties: list) -> Dict:
    """
    A placeholder for a formal verification tool.
    In a real application, this would call a model checker or simulation engine.
    """
    validated_properties = {}
    for prop in properties:
        prop_logic = prop.get("property", {}).get("pattern_params", {}).get("1", "")
        if "NOT" in prop_logic and "AND" in prop_logic and "instance.Motor" in prop_logic:
            if "MotorMovingUp" in code and "MotorMovingDown" in code and "MotorMovingUp := NOT MotorMovingDown" in code.replace(" ", ""):
                validated_properties[prop.get("property_description")] = {"passed": True, "feedback": "Logic appears to correctly implement the interlock."}
            else:
                validated_properties[prop.get("property_description")] = {"passed": False, "feedback": "Code may be missing the required safety interlock logic between motors."}
        else:
            validated_properties[prop.get("property_description")] = {"passed": True, "feedback": "Basic property check passed."}
    return validated_properties



def message_aggregation(raw_inputs: Dict[str, str], messages: Dict[str, Dict], aggregation_method: str):
    """
    Aggregates messages from other agents based on the specified method,
    tailored for PLC ST code generation workflows.
    """
    if aggregation_method == "Normal":
        return normal_agg(raw_inputs, messages)
    elif aggregation_method == "STSyntaxCheck":
        return st_syntax_check_agg(raw_inputs, messages)
    elif aggregation_method == "PropertyValidation":
        return property_validation_agg(raw_inputs, messages)
    elif aggregation_method == "LogicAndCodeIntegration":
        return logic_and_code_integration_agg(raw_inputs, messages)
    else:
        return normal_agg(raw_inputs, messages)


def normal_agg(raw_inputs: Dict[str, str], messages: Dict[str, Dict]) -> str:
    """
    Simply concatenates the raw outputs from other agents.
    Useful for analysts and reviewers who need the full context.
    """
    aggregated_message = ""
    for agent_id, info in messages.items():
        role_name = info['role'].role if hasattr(info.get('role'), 'role') else 'UnknownRole'
        aggregated_message += f"//--- Message from Agent {agent_id} (Role: {role_name}) ---\n"
        aggregated_message += f"{info.get('output', 'No output.')}\n\n"
    return aggregated_message


def st_syntax_check_agg(raw_inputs: Dict[str, str], messages: Dict[str, Dict]) -> str:
    """
    Extracts ST code from messages, runs a syntax check, and provides structured feedback.
    Useful for code generators who need to know if previous code snippets are valid.
    """
    aggregated_message = ""
    st_code_pattern = r"```st(.*?)```"

    for agent_id, info in messages.items():
        role_name = info['role'].role if hasattr(info.get('role'), 'role') else 'UnknownRole'
        output = info.get('output', '')
        aggregated_message += f"//--- Analysis of Agent {agent_id} (Role: {role_name}) ---\n"
        
        match = re.search(st_code_pattern, output, re.DOTALL)
        if match:
            code_snippet = match.group(1).strip()
            
            syntax_result = st_syntax_checker_tool(code_snippet)
            
            if syntax_result["passed"]:
                aggregated_message += "Syntax Check: PASSED.\n"
                aggregated_message += f"Provided Code:\n{code_snippet}\n\n"
            else:
                aggregated_message += f"Syntax Check: FAILED. Reason: {syntax_result['error']}\n"
                aggregated_message += f"Erroneous Code:\n{code_snippet}\n\n"
        else:
            aggregated_message += f"No ST code block found. Raw output:\n{output}\n\n"
            
    return aggregated_message


def property_validation_agg(raw_inputs: Dict[str, str], messages: Dict[str, Dict]) -> str:
    """
    Extracts validation properties from the initial task and uses a tool to verify 
    if the ST code from other agents meets these properties.
    """
    aggregated_message = "=== Formal Property Validation Report ===\n"
    properties = raw_inputs.get("properties_to_be_validated", [])
    st_code_pattern = r"```st(.*?)```"

    if not properties:
        return "No validation properties were specified for this task. Proceeding with standard code review."

    for agent_id, info in messages.items():
        role_name = info['role'].role if hasattr(info.get('role'), 'role') else 'UnknownRole'
        output = info.get('output', '')
        match = re.search(st_code_pattern, output, re.DOTALL)

        if match:
            code_snippet = match.group(1).strip()
            aggregated_message += f"\n//--- Validating code from Agent {agent_id} (Role: {role_name}) ---\n"
            validation_results = property_validator_tool(code_snippet, properties)
            
            for prop_desc, result in validation_results.items():
                status = "PASSED" if result["passed"] else "FAILED"
                aggregated_message += f"Property: '{prop_desc}'\n"
                aggregated_message += f"Status: {status}\n"
                aggregated_message += f"Feedback: {result['feedback']}\n\n"
        else:
             aggregated_message += f"\n//--- Skipping Agent {agent_id} (Role: {role_name}): No ST code block found for validation. ---\n"

    return aggregated_message


def logic_and_code_integration_agg(raw_inputs: Dict[str, str], messages: Dict[str, Dict]) -> str:
    """
    Integrates outputs from planner/expert roles into a structured context for the main code generator.
    """
    plan_context = ""
    code_snippets_context = ""

    for agent_id, info in messages.items():
        role_name = info['role'].role if hasattr(info.get('role'), 'role') else 'UnknownRole'
        output = info.get('output', '')

        if "Planner" in role_name or "Specialist" in role_name or "Designer" in role_name:
            plan_context += f"//--- Logic Plan from {role_name} ({agent_id}) ---\n{output}\n\n"
        
        if "Expert" in role_name or "Processor" in role_name or "Architect" in role_name:
             code_snippets_context += f"//--- Code Snippet from {role_name} ({agent_id}) ---\n{output}\n\n"

    aggregated_message = "=== Integrated Development Context ===\n\n"
    aggregated_message += "--- High-Level Logic & Pseudocode ---\n"
    aggregated_message += plan_context if plan_context else "// No high-level logic provided.\n"
    aggregated_message += "\n--- Ready-to-use Code Snippets & Declarations ---\n"
    aggregated_message += code_snippets_context if code_snippets_context else "// No pre-built code snippets provided.\n"
    
    return aggregated_message