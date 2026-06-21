FUNCTION_BLOCK FB_RequestHandler
VAR_INPUT
    request : BOOL;
    done : BOOL;
END_VAR

VAR_OUTPUT
    listen : BOOL;
END_VAR

VAR
    state : INT := 0;
    nextState : INT := 0;
END_VAR

CASE state OF
    0:
        // State 0: Idle/Listening state
        listen := TRUE;
        
        // Transition logic
        IF request THEN
            listen := FALSE;
            nextState := 1;
        ELSE
            nextState := 0;
        END_IF;
        
    1:
        // State 1: Processing state
        listen := FALSE;
        
        // Transition logic
        IF done THEN
            listen := TRUE;
            nextState := 0;
        ELSE
            nextState := 1;
        END_IF;
        
    ELSE
        // Error/Default case
        listen := FALSE;
        nextState := 0;
END_CASE;

// Update state for next cycle
state := nextState;

END_FUNCTION_BLOCK;