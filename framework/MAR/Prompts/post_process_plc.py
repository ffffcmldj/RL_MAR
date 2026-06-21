# import re
# from typing import Dict
# # --- 新增 Imports ---
# from MAR.Tools.PLC.antlr_compiler import SclCompiler 
# from MAR.Tools.PLC.callCodesys import compile_and_run_codesys # 假设这是 callCodesys.py 中的主函数

# # --- 新增全局实例 ---
# # 初始化一个全局的 ANTLR 编译器实例，避免在每次调用时重复加载
# antlr_linter = SclCompiler()

# # -----------------------------------------------------------------------------------
# # Placeholder Tool Implementations
# # In a real-world application, these functions would interface with actual
# # static analysis tools, compilers, or formal verification engines.
# # -----------------------------------------------------------------------------------

# def st_syntax_checker_tool(code: str) -> Dict:
#     """
#     [真实工具] 使用 ANTLR Linter 对 ST 代码进行快速语法检查。
#     """
#     syntax_errors = antlr_linter.compile(code) #

#     if not syntax_errors: # 错误列表为空
#         return {"passed": True, "feedback": "ANTLR 语法检查通过。"}
#     else:
#         # 格式化 ANTLR 返回的错误
#         error_feedback = "\n".join([f"Syntax Error on line {err.line}: {err.msg}" for err in syntax_errors])
#         return {"passed": False, "feedback": error_feedback}

# def property_validator_tool(code: str, properties: list) -> Dict:
#     """
#     A placeholder for a formal verification or simulation tool.
#     It simulates checking if the code satisfies a list of formal properties.
#     """
#     # This is a highly simplified simulation. A real implementation would be far more complex.
#     validation_report = {}
#     for prop in properties:
#         prop_desc = prop.get("property_description", "Unknown Property")
#         # In a real tool, we would parse the logic. Here, we'll just use a placeholder.
#         # For demonstration, we'll assume it passes unless it's a known complex safety rule.
#         if "simultaneously" in prop_desc or "interlock" in prop_desc:
#              validation_report[prop_desc] = {"passed": False, "feedback": "Failed: This property requires complex interlock logic that needs manual verification or a formal model checker."}
#         else:
#             validation_report[prop_desc] = {"passed": True, "feedback": "Passed: The code structure appears to satisfy this property."}
#     return validation_report

# # -----------------------------------------------------------------------------------
# # Main Post-Processing Logic
# # -----------------------------------------------------------------------------------

# def post_process(raw_inputs: Dict[str, str], output: str, post_method: str) -> str:
#     if post_method is None or post_method == "None":
#         return output
#     elif post_method == "STSyntaxCheck":
#         return st_syntax_check(output)
#     elif post_method == "CodesysSemanticCheck": # <-- 新增
#         return codesys_semantic_check(output)
#     else:
#         return output

# # --- 保留 st_syntax_check(output) 函数 ---
# # 您在 post_process_plc.py 中已有的 st_syntax_check 函数很好，它调用 st_syntax_checker_tool，无需更改。

# # --- 移除/替换 property_validation 和 property_validator_tool ---
# # 我们可以完全移除 property_validator_tool 和 property_validation(raw_inputs, output) 函数，
# # 并用下面的函数替换它们：

# # --- 新增此函数 ---
# def codesys_semantic_check(output: str) -> str:
#     """
#     [真实工具] 提取 ST 代码, 调用 CODESYS 编译引擎进行完整的语义验证, 并附加报告。
#     """
#     # 尝试从 ```st ... ``` 块中提取代码
#     st_code_pattern = r"```st(.*?)```" 
#     match = re.search(st_code_pattern, output, re.DOTALL)

#     code_snippet = ""
#     if match:
#         code_snippet = match.group(1).strip()
#     else:
#         # 如果未找到 markdown 块, 假定输出本身就是裸代码
#         # (这很重要，因为您的 plc.json 最终节点被指示输出裸代码)
#         code_snippet = output.strip()

#     if not code_snippet:
#          return output + "\n\n--- CODESYS 编译报告 ---\n错误：未在智能体输出中找到可编译的 ST 代码。"

#     # 调用重量级 CODESYS 编译器
#     try:
#         # 注意：compile_and_run_codesys 可能需要一个模板项目路径。
#         # 为简单起见，我们先假设它已配置为使用一个默认项目。
#         # 训练时我们会在 run_plc.py 中提供这个路径。
#         (compile_success, compiler_errors) = compile_and_run_codesys(st_code_content=code_snippet)

#         report = f"\n\n--- CODESYS 编译报告 ---\n"
#         if compile_success:
#             report += "STATUS: 编译成功 (语义验证通过)\n"
#             report += "DETAILS:\n" + (compiler_errors if compiler_errors else "无错误或警告。")
#         else:
#             report += "STATUS: 编译失败 (语义验证失败)\n"
#             report += "DETAILS:\n" + compiler_errors
#         report += "\n--------------------------------------\n"

#     except Exception as e:
#         report = f"\n\n--- CODESYS 编译报告 ---\nSTATUS: 编译执行器异常\nDETAILS: {str(e)}\n"

#     return output + report

# def st_syntax_check(output: str) -> str:
#     """
#     Extracts ST code from an agent's output, runs a syntax check,
#     and appends a formatted report.
#     """
#     st_code_pattern = r"```st(.*?)```" # Assumes code is in a ```st ... ``` block
#     match = re.search(st_code_pattern, output, re.DOTALL)

#     if not match:
#         return output + "\n\n--- SYNTAX CHECK REPORT ---\nNo ST code block found to check."

#     code_snippet = match.group(1).strip()
#     result = st_syntax_checker_tool(code_snippet)

#     report = f"\n\n--- IEC 61131-3 SYNTAX CHECK REPORT ---\n"
#     report += f"STATUS: {'PASSED' if result['passed'] else 'FAILED'}\n"
#     report += f"DETAILS:\n{result['feedback']}\n"
#     report += "--------------------------------------\n"

#     return output + report

# def property_validation(raw_inputs: Dict[str, str], output: str) -> str:
#     """
#     Extracts ST code and validation properties, runs a validation check,
#     and appends a formal report. This is for roles like CodeReviewerAndValidator.
#     """
#     properties = raw_inputs.get("properties_to_be_validated")
#     if not properties or not isinstance(properties, list):
#         return output + "\n\n--- FORMAL VALIDATION REPORT ---\nNo formal properties found in the task input to validate against."

#     st_code_pattern = r"```st(.*?)```"
#     match = re.search(st_code_pattern, output, re.DOTALL)

#     if not match:
#         return output + "\n\n--- FORMAL VALIDATION REPORT ---\nNo ST code block found to validate."

#     code_snippet = match.group(1).strip()
#     report_data = property_validator_tool(code_snippet, properties)

#     report = f"\n\n--- FORMAL PROPERTY VALIDATION REPORT ---\n"
#     for prop_desc, result in report_data.items():
#         status = "PASSED" if result["passed"] else "FAILED"
#         report += f"\nProperty: '{prop_desc}'\n"
#         report += f"  - Status: {status}\n"
#         report += f"  - Feedback: {result['feedback']}\n"
#     report += "-----------------------------------------\n"

#     return output + report

import re
from loguru import logger
from MAR.Tools.PLC.validators import st_syntax_checker_tool

# ST 代码块提取正则（预编译）
_ST_CODE_PATTERN = re.compile(r"```st(.*?)```", re.DOTALL | re.MULTILINE)

# CODESYS 编译错误格式化模板
_CODESYS_ERROR_HEADER = "\n\n[CODESYS Compilation Report]: The ST code above failed CODESYS compilation.\n"
_CODESYS_ERROR_FOOTER = "\nPlease fix ALL errors based on this report and regenerate the correct code."


def _extract_st_code(response: str) -> str:
    """从 LLM 回复中提取 ST 代码块，没找到则返回空字符串。"""
    match = _ST_CODE_PATTERN.search(response)
    if match:
        return match.group(1).strip()
    return ""


# IEC 61131-3 reserved words that conflict with built-in functions
_RESERVED_NAMES = {
    'min': 'MIN()', 'max': 'MAX()', 'len': 'LEN()', 'limit': 'LIMIT()',
    'sel': 'SEL()', 'mux': 'MUX()', 'sin': 'SIN()', 'cos': 'COS()',
    'tan': 'TAN()', 'exp': 'EXP()', 'expt': 'EXPT()', 'abs': 'ABS()',
    'sqrt': 'SQRT()', 'log': 'LOG()', 'ln': 'LN()', 'trunc': 'TRUNC()',
}


def _format_codesys_errors(errors: list) -> str:
    """Compress CODESYS errors by Error ID, filter cascade noise, add root-cause hints."""
    if not errors:
        return "Unknown compilation error."

    from collections import OrderedDict

    # Group by Error ID, preserving order of first occurrence
    groups = OrderedDict()
    for e in errors:
        eid = e.get("ID", "Unknown")
        if eid not in groups:
            groups[eid] = []
        groups[eid].append(e)

    PURE_CASCADE = {'C0189'}       # "expected X instead of Y" — pure parser noise
    SECONDARY = {'C0032', 'C0035'}  # type mismatch / need function name — cascade but informative

    root_lines = []
    secondary_lines = []
    cascade_lines = []

    for eid, group in groups.items():
        first = group[0]
        desc = first.get("ErrorDesc", str(first))
        count = len(group)
        count_str = f" x{count}" if count > 1 else ""
        hint = None

        if eid == 'C0046':  # Undefined identifier
            m = re.search(r"标识符'(\w+)'", desc)
            if m:
                name = m.group(1)
                lower = name.lower()
                if lower in _RESERVED_NAMES:
                    hint = f"HINT: '{name}' conflicts with built-in {_RESERVED_NAMES[lower]}. Rename this variable (e.g., {name}Value)."
                elif len(name) == 1 and name.isalpha():
                    hint = (f"HINT: '{name}' appears to be an undeclared FOR loop counter. "
                            "In IEC 61131-3, ALL loop counters must be explicitly declared "
                            f"in the VAR section (e.g., \"i : INT;\"). Add the declaration and retry.")
                else:
                    hint = f"HINT: '{name}' is not a standard IEC 61131-3 function. Use built-in equivalent (e.g., MIN) or define it yourself."

        elif eid == 'C0009':  # Unexpected token
            m = re.search(r"记号'(\w+)'", desc)
            if m:
                token = m.group(1)
                lower = token.lower()
                if lower in _RESERVED_NAMES:
                    hint = f"HINT: '{token}' is a reserved word (built-in {_RESERVED_NAMES[lower]}). Rename this variable."
                elif lower in ('function', 'end_function'):
                    hint = ("HINT: Nested POU detected. You cannot declare a FUNCTION inside a "
                            "FUNCTION_BLOCK. In IEC 61131-3, each POU must be standalone. "
                            "Move the nested POU outside, after END_FUNCTION_BLOCK of the main block.")

        elif eid == 'C0212':
            hint = ("HINT: Structural error — you cannot nest a FUNCTION or FUNCTION_BLOCK "
                    "inside another POU. In IEC 61131-3, each POU must be a standalone "
                    "top-level unit. Move the nested POU outside, placing it after the "
                    "END_FUNCTION_BLOCK of the main block.")

        elif eid == 'C0032':
            hint = "(cascade: type mismatch caused by an undefined identifier — fix C0046 errors first)"
        elif eid == 'C0035':
            hint = "(cascade: caused by an undefined identifier — fix C0046 errors first)"
        elif eid == 'C0189':
            hint = "(cascade: parser confused by an earlier unexpected token — fix C0009 errors first)"

        line = f"[{eid}{count_str}] {desc}"
        if hint:
            line += f"  ← {hint}"

        if eid in PURE_CASCADE:
            cascade_lines.append(line)
        elif eid in SECONDARY:
            secondary_lines.append(line)
        else:
            root_lines.append(line)

    all_lines = root_lines + secondary_lines + cascade_lines
    total = len(errors)
    unique = len(groups)
    header = f"{total} errors compressed to {unique} unique types:\n"

    return header + "\n".join(all_lines)


def _build_rename_hint(errors: list) -> str:
    """Scan CODESYS errors for naming conflicts with IEC 61131-3 built-ins.

    Returns a prominent rename instruction block, or empty string if none found.
    """
    conflicts = {}
    for e in errors:
        if e.get("ID") == "C0009":
            m = re.search(r"记号'(\w+)'", e.get("ErrorDesc", ""))
            if m:
                token = m.group(1)
                lower = token.lower()
                if lower in _RESERVED_NAMES:
                    conflicts[lower] = token

    if not conflicts:
        return ""

    items = []
    for low, orig in conflicts.items():
        suggestion = f"{orig}Value"
        items.append(f"  - '{orig}' conflicts with built-in {_RESERVED_NAMES[low]}. Rename to '{suggestion}'.")

    return (
        "\n\n"
        "========================================\n"
        "CRITICAL: Variable name conflicts with IEC 61131-3 built-in functions.\n"
        "Fix these FIRST — they cause cascading parser errors that hide other issues:\n"
        + "\n".join(items) +
        "\n========================================"
    )


def post_process(raw_inputs, response, method="None"):
    """
    对 Agent 的输出进行后处理。

    Args:
        raw_inputs: 原始输入数据
        response: LLM 生成的原始回复
        method: 后处理的方法名 (例如 "STSyntaxCheck", "CodesysSemanticCheck")

    Returns:
        tuple: (处理后的回复文本, validation_info dict)
        validation_info = {"passed": bool, "errors": [...]}
    """

    # 1. 如果没有指定方法，或者是 "None"，直接返回原始回复
    if method == "None" or not method:
        return response, {"passed": True, "errors": []}

    # 2. ST 语法检查模式（ANTLR）
    elif method == "STSyntaxCheck":
        code_snippet = _extract_st_code(response)
        if code_snippet:
            check_result = st_syntax_checker_tool(code_snippet)
            if check_result['passed']:
                return response, {"passed": True, "errors": []}
            else:
                error_msg = check_result.get('error', 'Unknown syntax error')
                error_feedback = (
                    f"\n\n[System Feedback]: The ST code above contains syntax errors:\n"
                    f"{error_msg}\n"
                    f"Please fix these errors."
                )
                return response + error_feedback, {"passed": False, "errors": [{"ErrorDesc": error_msg}]}
        else:
            return response, {"passed": True, "errors": []}

    # 3. CODESYS 语义验证模式
    elif method == "CodesysSemanticCheck":
        try:
            from MAR.Tools.PLC.codesys_client import get_codesys_client
            client = get_codesys_client()
        except ImportError:
            logger.warning("CODESYS client not available (import failed), falling back to ANTLR syntax check.")
            resp, info = post_process(raw_inputs, response, "STSyntaxCheck")
            info["codesys_used"] = False
            return resp, info

        code_snippet = _extract_st_code(response)
        if not code_snippet:
            return response, {"passed": True, "errors": [], "codesys_used": False}

        try:
            result = client.compile_code(code_snippet)
        except Exception as e:
            logger.warning(f"CODESYS server unreachable ({client.host}:{client.port}): {e}, falling back to ANTLR syntax check.")
            resp, info = post_process(raw_inputs, response, "STSyntaxCheck")
            info["codesys_used"] = False
            return resp, info

        if result.get("success", False):
            return response, {"passed": True, "errors": [], "codesys_used": True}
        else:
            errors = result.get("errors", [])
            error_text = _format_codesys_errors(errors)
            error_feedback = f"{_CODESYS_ERROR_HEADER}{error_text}{_CODESYS_ERROR_FOOTER}"
            return response + error_feedback, {"passed": False, "errors": errors, "codesys_used": True}

    # 4. 其他未定义的方法，默认返回原回复
    else:
        return response, {"passed": True, "errors": []}