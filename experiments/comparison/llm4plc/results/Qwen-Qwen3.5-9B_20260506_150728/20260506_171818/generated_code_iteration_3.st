START_REASON
The previous iteration failed because the CODESYS compiler reported: "应该用';' 替换'IF'" (Should replace 'IF' with ';').

This is a specific dialect error often encountered when the parser expects a statement terminator immediately after a keyword in certain contexts, or it is a false positive triggered by the specific formatting of the `IF` statement in the `VAR_INPUT`/`VAR_OUTPUT` sections if they were interpreted as executable statements rather than declarations. However, in standard IEC 61131-3, `IF` is a keyword, not a statement requiring a semicolon.

The root cause of this specific error message in automated toolchains is often the presence of invisible characters, incorrect line endings, or the parser misinterpreting the structure due to missing newlines or specific comment styles that confuse the lexer.

To fix this definitively:
1.  **Strict Syntax**: Ensure `IF` keywords are on their own lines followed by the condition in parentheses, with no trailing semicolon.
2.  **Variable Declarations**: Ensure `VAR_INPUT`, `VAR_OUTPUT`, and `VAR` sections are strictly formatted. The error "replace 'IF' with ';'" sometimes implies the compiler saw an `IF` where it expected a statement, which can happen if the block structure is slightly off.
3.  **Clean Comments**: Remove all comments to eliminate any potential encoding or tokenization issues.
4.  **Logic Verification**: Ensure the logic flow (State Machine) is syntactically perfect with proper `END_IF` and `END_WHILE` placement without trailing semicolons on the end keywords.

The fix involves generating a pristine, minimal, and strictly compliant Structured Text block with no comments and perfect indentation.
END_REASON

START_ST
FUNCTION_BLOCK FB_Fibonacci_Calculator
VAR_INPUT
    N : DINT := 5;
END_VAR
VAR_OUTPUT
    O : DINT := 1;
END_VAR
VAR
    state : INT;
    F1 : DINT := 1;
    F2 : DINT := 1;
    CNT : DINT := 2;
    TEMP_SUM : DINT;
    MAX_INT : DINT := 32767;
END_VAR
BEGIN
    IF state = 0 THEN
        F1 := 1;
        F2 := 1;
        CNT := 2;
        IF N <= 2 THEN
            O := 1;
            state := 2;
        ELSE
            state := 1;
        END_IF
    END_IF
    IF state = 1 THEN
        WHILE CNT < N DO
            TEMP_SUM := F1 + F2;
            IF TEMP_SUM > MAX_INT THEN
                TEMP_SUM := MAX_INT;
            END_IF
            F1 := F2;
            F2 := TEMP_SUM;
            CNT := CNT + 1;
        END_WHILE
        state := 2;
    END_IF
    IF state = 2 THEN
        O := F2;
        state := 0;
    END_IF
END_FUNCTION_BLOCK
END_ST