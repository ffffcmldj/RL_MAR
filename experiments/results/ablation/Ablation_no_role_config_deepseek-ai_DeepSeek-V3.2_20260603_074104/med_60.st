FUNCTION_BLOCK FB_RequestHandler
VAR_INPUT
    request : BOOL;
    done : BOOL;
END_VAR

VAR_OUTPUT
    listen : BOOL;
END_VAR

VAR
    currentState : INT := 0;
    nextState : INT := 0;
END_VAR

CASE currentState OF
    0: (* State 0 - Idle/Listening *)
        listen := TRUE;
        
        IF request THEN
            listen := FALSE;
            nextState := 1;
        ELSE
            nextState := 0;
        END_IF;
        
    1: (* State 1 - Processing *)
        listen := FALSE;
        
        IF done THEN
            listen := TRUE;
            nextState := 0;
        ELSE
            nextState := 1;
        END_IF;
        
    ELSE
        (* Default case - return to state 0 if invalid state *)
        currentState := 0;
        nextState := 0;
        listen := TRUE;
END_CASE;

currentState := nextState;
END_FUNCTION_BLOCK