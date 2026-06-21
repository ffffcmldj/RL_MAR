START_REASON
The previous code failed because the `CASE` statement in Structured Text (ST) requires a specific end marker: `END_CASE;`. The previous code used `ENDCASE` (all uppercase without the semicolon), which is not valid in the CODESYS compiler. Additionally, while the comments were changed to English, the specific syntax error regarding the case statement terminator is the primary blocker. I will correct `ENDCASE` to `END_CASE;` and ensure the file ends correctly.
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
END_CASE
END_FUNCTION_BLOCK
END_ST