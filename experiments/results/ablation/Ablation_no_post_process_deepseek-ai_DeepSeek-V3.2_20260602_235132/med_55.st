FUNCTION_BLOCK StateMachineControl
VAR_INPUT
    request : BOOL;
    done : BOOL;
END_VAR

VAR_OUTPUT
    listen : BOOL;
END_VAR

VAR
    state : INT := 0; (* 0 = Idle, 1 = Processing *)
END_VAR

(* State Machine Logic *)
CASE state OF
    0: (* Idle State *)
        listen := TRUE;
        
        (* Transition to Processing when request is TRUE *)
        IF request THEN
            state := 1;
            listen := FALSE;
        END_IF;
        
    1: (* Processing State *)
        listen := FALSE;
        
        (* Transition to Idle when done is TRUE *)
        IF done THEN
            state := 0;
        END_IF;
        
    ELSE
        (* Fallback to Idle state for safety *)
        state := 0;
        listen := TRUE;
END_CASE;

END_FUNCTION_BLOCK