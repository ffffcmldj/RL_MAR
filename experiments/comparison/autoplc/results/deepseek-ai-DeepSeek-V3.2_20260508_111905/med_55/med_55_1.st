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
    prev_request : BOOL := FALSE;
    prev_done : BOOL := FALSE;
END_VAR

// Main state machine logic
CASE state OF
    0: // Idle state
        // Set listen output to TRUE in Idle state
        listen := TRUE;
        
        // Check for rising edge of request signal
        IF request AND NOT prev_request THEN
            // Transition to Processing state
            state := 1;
            // Update listen output for new state
            listen := FALSE;
        END_IF;
        
    1: // Processing state
        // Set listen output to FALSE in Processing state
        listen := FALSE;
        
        // Check for rising edge of done signal
        IF done AND NOT prev_done THEN
            // Transition to Idle state
            state := 0;
            // Update listen output for new state
            listen := TRUE;
        END_IF;
        
    ELSE
        // Handle unexpected state - reset to Idle
        state := 0;
        listen := TRUE;
END_CASE;

// Store previous values for edge detection
prev_request := request;
prev_done := done;

END_FUNCTION_BLOCK