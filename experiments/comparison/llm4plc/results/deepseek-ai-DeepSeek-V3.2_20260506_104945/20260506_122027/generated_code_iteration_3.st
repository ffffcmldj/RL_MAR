START_REASON
The feedback indicates that the CODESYS compiler expects a semicolon ';' instead of 'UINT#'. This suggests that the type conversion syntax `UINT#II` is not valid in this context in CODESYS. In CODESYS Structured Text, type conversions are typically done using the `TYPE_TO_TYPE` syntax (e.g., `INT_TO_UINT`) or by directly assigning with type casting using parentheses. The `UINT#II` syntax might be specific to other PLC environments or incorrect. I need to replace `UINT#II` with a proper type conversion, such as `UINT(II)` or `INT_TO_UINT(II)`. Since the previous feedback mentioned changing `UINT(II)` to `UINT#II` for compatibility, but now CODESYS rejects `UINT#`, I'll revert to `UINT(II)` or use `INT_TO_UINT(II)`. I'll use `UINT(II)` as it's a common casting method in CODESYS. Also, I'll ensure all syntax is correct and maintain the function block structure. The error is in line `tempSum := tempSum + UINT#II;`—I'll change it to `tempSum := tempSum + UINT(II);`. This should resolve the CODESYS compiler error.
END_REASON

START_ST
FUNCTION_BLOCK FB_Sum
VAR_INPUT
    maxValue : INT;
    execute : BOOL;
END_VAR
VAR_OUTPUT
    wData : WORD;
    done : BOOL;
END_VAR
VAR
    state : INT;
    prevExecute : BOOL;
    II : INT;
    tempSum : UINT;
END_VAR

CASE state OF
    0:
        done := FALSE;
        II := 0;
        tempSum := 0;
        IF (execute = TRUE) AND (prevExecute = FALSE) THEN
            state := 1;
        END_IF;
    1:
        IF II <= maxValue THEN
            tempSum := tempSum + UINT(II);
            II := II + 1;
        ELSE
            state := 2;
        END_IF;
    2:
        wData := WORD(tempSum);
        done := TRUE;
        II := 0;
        IF execute = FALSE THEN
            state := 0;
        END_IF;
END_CASE;

prevExecute := execute;
END_FUNCTION_BLOCK
END_ST