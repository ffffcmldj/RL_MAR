(*
FUNCTION_BLOCK: FB_RequestHandler
DESCRIPTION: Implements a state machine for request handling with listening mode control.
INPUTS:
    request : BOOL - Indicates if a request has been made
    done    : BOOL - Indicates if processing is completed
OUTPUTS:
    listen  : BOOL - Indicates whether the system is in listening mode
BEHAVIOR:
    State 0 (Idle): 
        - listen = TRUE
        - If request = TRUE: Transition to State 1, set listen = FALSE
    State 1 (Processing):
        - listen = FALSE
        - If done = TRUE: Transition to State 0, set listen = TRUE
*)

FUNCTION_BLOCK FB_RequestHandler
VAR_INPUT
    request : BOOL;
    done    : BOOL;
END_VAR

VAR_OUTPUT
    listen : BOOL;
END_VAR

VAR
    state : INT := 0;
END_VAR

(* Main state machine logic *)
CASE state OF
    0: (* State 0: Idle/Listening *)
        listen := TRUE;
        
        IF request THEN
            listen := FALSE;
            state := 1;
        END_IF;
        
    1: (* State 1: Processing/Not Listening *)
        listen := FALSE;
        
        IF done THEN
            listen := TRUE;
            state := 0;
        END_IF;
        
END_CASE;

END_FUNCTION_BLOCK;