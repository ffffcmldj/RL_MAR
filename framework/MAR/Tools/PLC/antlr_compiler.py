import sys
import os
from antlr4 import *
from antlr4.error.ErrorListener import ErrorListener

try:
    from .Grammar.sclLexer import sclLexer
    from .Grammar.sclParser import sclParser
except ImportError:
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
        error_msg = f"Line {line}:{column} - {msg}"
        self.errors.append(error_msg)

class STCompiler:
    def __init__(self):
        pass

    def check_syntax(self, code_string: str):
        """
        Perform static syntax check using ANTLR.
        """
        if not code_string or not code_string.strip():
            return {"passed": False, "errors": ["Empty code input"]}

        try:
            input_stream = InputStream(code_string)
            lexer = sclLexer(input_stream)
            
            error_listener = SyntaxErrorListener()

            lexer.removeErrorListeners()
            lexer.addErrorListener(error_listener)
            
            stream = CommonTokenStream(lexer)
            parser = sclParser(stream)
            
            parser.removeErrorListeners()
            parser.addErrorListener(error_listener)

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
    compiler = STCompiler()
    code_ok = "FUNCTION_BLOCK Test VAR x:INT; END_VAR x:=1; END_FUNCTION_BLOCK"
    print(f"Test OK: {compiler.check_syntax(code_ok)['passed']}")
    
    code_err = "FUNCTION_BLOCK Test VAR x:INT END_VAR"  # Missing semicolon
    print(f"Test Err: {compiler.check_syntax(code_err)['passed']}")
