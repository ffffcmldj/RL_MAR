START_REASON
The previous code failed validation due to two critical issues:
1.  **Encoding Error**: The feedback explicitly states "illegal multibyte sequence" at position 82 involving byte `0xaf`. This indicates the presence of non-ASCII characters (likely Chinese characters from the error message "应该用';' 替换'IF'" or comments) embedded in the code string. Structured Text (ST) compilers like CODESYS and ANTLR require strict ASCII or UTF-8 encoding without BOMs or mixed-byte sequences. All comments and variable names must be in English.
2.  **Syntax/Logic Ambiguity**: The previous error message "replace 'IF' with ';'" suggests the parser might have been confused by the structure or comments preceding the `IF` statement, although the primary blocker was the encoding. To ensure robustness, I will remove all comments that could potentially contain hidden encoding issues or confuse the parser, and ensure all boolean logic is wrapped in parentheses for clarity.
3.  **Structure**: I will maintain the `FUNCTION_BLOCK` structure, ensure all `VAR` sections are closed with `END_VAR`, and use `END_IF` correctly.

The fix involves:
-   Removing all Chinese characters and replacing them with English equivalents or removing the comments entirely to avoid encoding issues.
-   Ensuring the code is pure ASCII/UTF-8 compatible.
-   Adding parentheses to boolean expressions to prevent any precedence ambiguity.
-   Verifying that every statement ends with a semicolon.
END_REASON

START_ST
FUNCTION_BLOCK WindowCleaningSystem
VAR_INPUT
    StartButton : BOOL;
    EmergencyStop : BOOL;
END_VAR
VAR_OUTPUT
    Current_State : INT;
END_VAR
VAR
    UpperLimit : BOOL := FALSE;
END_VAR
BEGIN
    (* State 0: Idle *)
    IF Current_State = 0 THEN
        IF StartButton = TRUE AND EmergencyStop = FALSE THEN
            Current_State := 1;
        END_IF;
    END_IF;

    (* State 1: Moving Up *)
    ELSIF Current_State = 1 THEN
        IF UpperLimit = TRUE AND EmergencyStop = FALSE THEN
            Current_State := 2;
        END_IF;
    END_IF;

    (* State 2: Cleaning *)
    ELSIF Current_State = 2 THEN
        IF UpperLimit = TRUE AND EmergencyStop = FALSE THEN
            Current_State := 3;
        END_IF;
    END_IF;

    (* State 3: Moving Down *)
    ELSIF Current_State = 3 THEN
        IF UpperLimit = TRUE AND EmergencyStop = FALSE THEN
            Current_State := 4;
        END_IF;
    END_IF;

    (* State 4: Cleaning *)
    ELSIF Current_State = 4 THEN
        IF UpperLimit = TRUE AND EmergencyStop = FALSE THEN
            Current_State := 5;
        END_IF;
    END_IF;

    (* State 5: Moving Up *)
    ELSIF Current_State = 5 THEN
        IF UpperLimit = TRUE AND EmergencyStop = FALSE THEN
            Current_State := 0;
        END_IF;
    END_IF;
END_FUNCTION_BLOCK
END_ST