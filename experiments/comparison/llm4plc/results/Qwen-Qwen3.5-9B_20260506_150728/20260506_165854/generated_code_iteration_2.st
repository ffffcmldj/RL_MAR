START_REASON
The previous code failed due to a character encoding issue. The error message "illegal multibyte sequence" and the specific byte `0xaf` indicate that the source code contained non-ASCII characters (likely Chinese comments like `(* STATE 0: IDLE *)` or similar) that were not properly encoded for the CODESYS compiler (which typically expects UTF-8 or ASCII). The compiler cannot parse these bytes, causing the syntax check to fail before it can even analyze the logic.

To fix this, I will:
1.  Remove all non-ASCII characters (Chinese comments) and replace them with standard English comments.
2.  Ensure the entire code block is strictly ASCII/UTF-8 compatible.
3.  Maintain the `FUNCTION_BLOCK` structure and `END_VAR` usage as required.
4.  Verify that all `IF` statements follow the standard `IF condition THEN ... END_IF;` syntax without any encoding artifacts.
END_REASON

START_ST
FUNCTION_BLOCK StateMachine
    VAR
        StartButton : BOOL;
        StopButton : BOOL;
        state : INT := 0;
        stopRequested : BOOL := FALSE;
    END_VAR

    (* Main Logic *)
    IF StartButton = TRUE AND StopButton = FALSE THEN
        stopRequested := FALSE;
    ELSE
        stopRequested := TRUE;
    END_IF;

    CASE state OF
        0: (* STATE 0: IDLE *)
            IF StartButton = TRUE AND StopButton = FALSE THEN
                state := 1;
            END_IF;
        1: (* STATE 1: RUNNING *)
            IF StartButton = FALSE AND StopButton = TRUE THEN
                state := 0;
            END_IF;
        2: (* STATE 2: ERROR *)
            IF StartButton = TRUE THEN
                state := 1;
            END_IF;
    ENDCASE
END_FUNCTION_BLOCK
END_ST