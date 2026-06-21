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
END_VAR

// State machine implementation
CASE state OF
    0: // State 0: Listening state
        IF request THEN
            // Transition to state 1 when request is TRUE
            listen := FALSE;
            state := 1;
        ELSE
            // Remain in state 0 when request is FALSE
            listen := TRUE;
            state := 0;
        END_IF;
        
    1: // State 1: Processing state
        IF done THEN
            // Transition back to state 0 when done is TRUE
            listen := TRUE;
            state := 0;
        ELSE
            // Remain in state 1 when done is FALSE
            listen := FALSE;
            state := 1;
        END_IF;
        
    ELSE
        // Default case: reset to state 0 if state becomes invalid
        listen := TRUE;
        state := 0;
END_CASE;

END_FUNCTION_BLOCK