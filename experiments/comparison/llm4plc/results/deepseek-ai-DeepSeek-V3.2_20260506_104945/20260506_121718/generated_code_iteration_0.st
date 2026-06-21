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

CASE state OF
    0: // IDLE state
        listen := TRUE;
        IF request THEN
            state := 1; // Transition to PROCESSING state
        END_IF;
        
    1: // PROCESSING state
        listen := FALSE;
        IF done THEN
            state := 0; // Transition to IDLE state
        END_IF;
        
    ELSE
        // Fallback to IDLE state if state value is invalid
        state := 0;
        listen := TRUE;
END_CASE;

END_FUNCTION_BLOCK
END_ST