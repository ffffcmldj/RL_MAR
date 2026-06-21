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

(* State Machine Logic *)
CASE state OF
    0: (* Idle State *)
        listen := TRUE;
        
        IF request THEN
            state := 1;  (* Transition to Processing *)
            listen := FALSE;
        END_IF;
        
    1: (* Processing State *)
        listen := FALSE;
        
        IF done THEN
            state := 0;  (* Transition to Idle *)
            listen := TRUE;
        END_IF;
        
    ELSE
        (* Safety fallback: Reset to Idle state *)
        state := 0;
        listen := TRUE;
END_CASE;

END_FUNCTION_BLOCK;