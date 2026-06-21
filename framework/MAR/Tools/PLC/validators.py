# MAR/Tools/PLC/validators.py

from typing import Dict, List
import re
# 确保这里能正确导入同目录下的编译器
try:
    from .antlr_compiler import STCompiler
except ImportError:
    from MAR.Tools.PLC.antlr_compiler import STCompiler

# 初始化单例
_antlr_compiler = STCompiler()

def st_syntax_checker_tool(code: str) -> Dict:
    """
    ST 语法检查适配器 (智能版)
    
    功能:
    1. 清洗 Markdown 标记
    2. [智能适配] 自动判断是"代码片段"还是"完整程序"，决定是否需要包装
    3. 调用编译器进行检查
    """
    # 1. 预处理：清洗 Markdown
    if not code:
        return {"passed": False, "error": "Empty input"}
        
    clean_code = code.replace("```st", "").replace("```", "").strip()
    
    if not clean_code:
        return {"passed": False, "error": "Empty code block after cleaning"}

    # 2. [核心修复] 智能判断是否需要包装
    # 检查代码中是否已经包含了 FUNCTION_BLOCK, PROGRAM 或 FUNCTION 等关键字
    # 使用正则忽略大小写
    has_block_structure = re.search(r'\b(FUNCTION_BLOCK|PROGRAM|FUNCTION)\b', clean_code, re.IGNORECASE)

    if has_block_structure:
        # 情况 A: AI 已经写了完整的块 -> 直接送检，不要再包了！
        final_code = clean_code
    else:
        # 情况 B: AI 只写了片段 (如 x:=y;) -> 给它穿个马甲，骗过编译器
        final_code = f"""
FUNCTION_BLOCK RL_MAR_Auto_Check
    VAR_TEMP
       // 预留区域
    END_VAR
    BEGIN
        {clean_code}
    
END_FUNCTION_BLOCK
"""

    # 3. 调用 ANTLR 检查
    # 注意：这里的检查结果会包含行号，如果是包装过的代码，行号会偏移，但为了调试方便暂不处理
    result = _antlr_compiler.check_syntax(final_code)
    
    # 4. 格式化返回结果
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