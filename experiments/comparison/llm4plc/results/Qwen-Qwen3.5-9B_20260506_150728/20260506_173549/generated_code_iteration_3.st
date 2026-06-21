START_REASON
The previous code failed validation due to a character encoding error ("illegal multibyte sequence" at byte 0xaf). This indicates that the Structured Text (ST) code contains non-ASCII characters (likely Chinese characters from the error message or comments) which are not compatible with the standard IEC 61131-3 encoding expected by the CODESYS compiler (usually ASCII or UTF-8 without BOM).

Additionally, the previous error message "应该用';' 替换'MaxDuration'" (Should replace 'MaxDuration' with ';') suggested a syntax issue where a variable name was expected to be followed by a semicolon, often implying a missing declaration terminator or a malformed line.

To fix this:
1.  **Remove all non-ASCII characters**: Ensure the code is pure ASCII. No Chinese comments or error messages should be present in the source code.
2.  **Ensure strict syntax compliance**: Verify that all variable declarations end with a semicolon `;`.
3.  **Correct Variable Declaration**: Ensure `MaxDuration` is declared correctly. While `CONST` is standard, sometimes moving initialized constants to `VAR` (with initialization) or ensuring the `CONST` block syntax is perfectly clean resolves encoding or parsing ambiguities in specific compiler configurations. I will use `VAR` with initialization for `MaxDuration` to ensure it is treated as a standard variable declaration which is universally supported, or keep `CONST` but ensure it is strictly ASCII and properly terminated. Given the "Replace X with ;" error often stems from parsing confusion, declaring it in `VAR` with `:=` is the most robust solution for a simple constant value in an FB.
4.  **Verify Block Structure**: Ensure `FUNCTION_BLOCK`, `VAR`, `END_VAR`, and `END_FUNCTION_BLOCK` are correctly nested and closed.

The primary fix is to strip out any hidden or explicit non-ASCII characters and ensure the syntax is standard ASCII ST.
END_REASON

START_ST
FUNCTION_BLOCK MotionControl
VAR
    state : INT := 0;
    prevMotion : BOOL := FALSE;
    timerActive : TON;
    safetyInterlock : BOOL := TRUE;
    MaxDuration : TIME := T#300S;
END_VAR

VAR_INPUT
    MotionSensor : BOOL;
END_VAR

VAR_OUTPUT
    IsMoving : BOOL;
END_VAR

BEGIN
    timerActive(IN := MotionSensor, PT := MaxDuration);
    
    IF timerActive.Q THEN
        state := 1;
        IsMoving := TRUE;
    ELSE
        state := 0;
        IsMoving := FALSE;
    END_IF;
    
    prevMotion := MotionSensor;
END_FUNCTION_BLOCK
END_ST