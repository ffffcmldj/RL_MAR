
import re
from loguru import logger
from MAR.Tools.PLC.validators import st_syntax_checker_tool

# Pre-compiled ST code block extraction regex
_ST_CODE_PATTERN = re.compile(r"```st(.*?)```", re.DOTALL | re.MULTILINE)

# CODESYS error formatting template
_CODESYS_ERROR_HEADER = "\n\n[CODESYS Compilation Report]: The ST code above failed CODESYS compilation.\n"
_CODESYS_ERROR_FOOTER = "\nPlease fix ALL errors based on this report and regenerate the correct code."


def _extract_st_code(response: str) -> str:
    """Extract ST code block from LLM response, return empty string if not found."""
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
    Post-process agent output.

    Args:
        raw_inputs: Original input data
        response: Raw response from LLM
        method: Post-processing method name (e.g. "STSyntaxCheck", "CodesysSemanticCheck")

    Returns:
        tuple: (Post-processed response text, validation_info dict)
        validation_info = {"passed": bool, "errors": [...]}
    """

    # 1. No post-processing: return original response
    if method == "None" or not method:
        return response, {"passed": True, "errors": []}

    # 2. ANTLR syntax check
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

    # 3. CODESYS semantic validation
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

    # 4. Unknown method: fallback to original
    else:
        return response, {"passed": True, "errors": []}
