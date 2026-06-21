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