START_REASON
The error "发现非预期的记号'END_VAR'" (Unexpected token 'END_VAR') indicates a syntax violation in the CODESYS Structured Text (ST) compiler.

Analysis of the error:
1.  **Incorrect Closing Tag for Function Block**: In CODESYS ST, a `FUNCTION_BLOCK` definition must be closed with `END_FUNCTION_BLOCK`. The provided code incorrectly used `END_VAR` to close the main body of the function block.
2.  **Redundant/Incorrect Closing Tag**: The code has `END_VAR` immediately after the `VAR` section, which is acceptable in some contexts but often redundant or confusing if not followed by the correct block terminator. However, the critical error is using `END_VAR` instead of `END_FUNCTION_BLOCK` at the end of the block definition.
3.  **Structure**: The `BEGIN...END` block for the logic is correct, but it must be followed by the specific terminator for the `FUNCTION_BLOCK`.

Fix Plan:
1.  Keep the `START_ST` and `END_ST` markers.
2.  Ensure the `VAR_INPUT`, `VAR_OUTPUT`, and `VAR` sections are correctly formatted.
3.  Replace the final `END_VAR` with `END_FUNCTION_BLOCK`.
4.  Ensure the logic inside the `BEGIN...END` block remains intact.
END_REASON

START_ST
FUNCTION_BLOCK StateMachineControl
VAR_INPUT
    request : BOOL;
    done : BOOL;
END_VAR
VAR_OUTPUT
    listen : BOOL;
END_VAR
VAR
    state : INT := 0;
END_VAR
VAR_TEMP
END_VAR

BEGIN
    (* STATE 0: IDLE *)
    (* Behavior: listen = TRUE when no request is present *)
    (* Transition: To Processing if request is TRUE *)
    IF state = 0 THEN
        listen := NOT request;
        
        (* Check transition condition: Idle AND Request is TRUE *)
        IF request = TRUE THEN
            state := 1; (* Transition to Processing *)
        END_IF;
    END_IF;

    (* STATE 1: PROCESSING *)
    (* Behavior: listen = FALSE *)
    (* Transition: To Idle if done is TRUE *)
    IF state = 1 THEN
        listen := FALSE;
        
        (* Check transition condition: Processing AND Done is TRUE *)
        IF done = TRUE THEN
            state := 0; (* Transition to Idle *)
        END_IF;
    END_IF;
END_FUNCTION_BLOCK
END_ST