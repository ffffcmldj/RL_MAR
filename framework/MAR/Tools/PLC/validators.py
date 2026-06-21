
from typing import Dict, List
import re
try:
    from .antlr_compiler import STCompiler
except ImportError:
    from MAR.Tools.PLC.antlr_compiler import STCompiler

_antlr_compiler = STCompiler()

def st_syntax_checker_tool(code: str) -> Dict:
    if not code:
        return {"passed": False, "error": "Empty input"}
        
    clean_code = code.replace("```st", "").replace("```", "").strip()
    
    if not clean_code:
        return {"passed": False, "error": "Empty code block after cleaning"}

    has_block_structure = re.search(r'\b(FUNCTION_BLOCK|PROGRAM|FUNCTION)\b', clean_code, re.IGNORECASE)

    if has_block_structure:
        final_code = clean_code
    else:
        final_code = f"""
FUNCTION_BLOCK RL_MAR_Auto_Check
    VAR_TEMP
       // 预留区域
    END_VAR
    BEGIN
        {clean_code}
    
END_FUNCTION_BLOCK
"""

    result = _antlr_compiler.check_syntax(final_code)
    
    if result['passed']:
        return {
            "passed": True,
            "error": None,
            "feedback": "Syntax check passed successfully."
        }
    else:
        error_msg = "\n".join(result['errors'])
        return {
            "passed": False,
            "error": error_msg,
            "feedback": f"Syntax check failed:\n{error_msg}"
        }

def property_validator_tool(code: str, properties: List) -> Dict:
    """
    Placeholder for future logic verification.
    """
    return {
        "all_passed": True,
        "details": {}
    }