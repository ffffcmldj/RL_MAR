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
    0: // Idle state
        listen := TRUE;
        IF request THEN
            state := 1;
            listen := FALSE;
        END_IF;
        
    1: // Processing state
        listen := FALSE;
        IF done THEN
            state := 0;
        END_IF;
        
    ELSE
        // Handle unexpected state values
        state := 0;
        listen := FALSE;
END_CASE;

END_FUNCTION_BLOCK