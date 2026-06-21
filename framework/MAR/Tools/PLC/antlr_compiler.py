import sys
import os
from antlr4 import *
from antlr4.error.ErrorListener import ErrorListener

# --- 优化点 1: 使用规范的相对导入 ---
# 前提：确保 Grammar 文件夹下有 __init__.py 文件
try:
    from .Grammar.sclLexer import sclLexer
    from .Grammar.sclParser import sclParser
except ImportError:
    # 备用：如果直接作为脚本运行 (python antlr_compiler.py)
    # 则需要把父目录加入路径才能找到 Grammar
    try:
        from Grammar.sclLexer import sclLexer
        from Grammar.sclParser import sclParser
    except ImportError:
        print("❌ Critical Error: ANTLR generated files not found in Grammar/ folder.")
        print("Please run: java -jar antlr-4.13.1-complete.jar -Dlanguage=Python3 scl.g4")
        raise

class SyntaxErrorListener(ErrorListener):
    def __init__(self):
        super(SyntaxErrorListener, self).__init__()
        self.errors = []

    def syntaxError(self, recognizer, offendingSymbol, line, column, msg, e):
        # 优化错误信息格式，使其更易读
        error_msg = f"Line {line}:{column} - {msg}"
        self.errors.append(error_msg)

class STCompiler:
    def __init__(self):
        pass

    def check_syntax(self, code_string: str):
        """
        使用 ANTLR 进行静态语法检查
        """
        if not code_string or not code_string.strip():
            return {"passed": False, "errors": ["Empty code input"]}

        try:
            input_stream = InputStream(code_string)
            lexer = sclLexer(input_stream)
            
            # 初始化错误监听器
            error_listener = SyntaxErrorListener()

            # 替换 Lexer 的默认监听器 (去除控制台噪音)
            lexer.removeErrorListeners()
            lexer.addErrorListener(error_listener)
            
            stream = CommonTokenStream(lexer)
            parser = sclParser(stream)
            
            # 替换 Parser 的默认监听器
            parser.removeErrorListeners()
            parser.addErrorListener(error_listener)

            # --- 优化点 2: 增加解析超时或深度限制保护 (可选，防止死循环) ---
            # 目前保持原样调用入口规则 block*
            # 你的 .g4 文件里入口规则叫 'r'
            tree = parser.r() 
            
        except Exception as e:
            return {"passed": False, "errors": [f"Parser internal error: {str(e)}"]}

        if error_listener.errors:
            return {
                "passed": False, 
                "errors": error_listener.errors
            }
        else:
            return {
                "passed": True, 
                "errors": []
            }

if __name__ == "__main__":
    # 单元测试
    compiler = STCompiler()
    # 测试一个正确的
    code_ok = "FUNCTION_BLOCK Test VAR x:INT; END_VAR x:=1; END_FUNCTION_BLOCK"
    print(f"Test OK: {compiler.check_syntax(code_ok)['passed']}")
    
    # 测试一个错误的
    code_err = "FUNCTION_BLOCK Test VAR x:INT END_VAR" # 缺少分号
    print(f"Test Err: {compiler.check_syntax(code_err)['passed']}")