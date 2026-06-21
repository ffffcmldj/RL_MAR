ructured-text
FUNCTION_BLOCK FB_RequestHandler
VAR_IN
    request : BOOL; // Input for request signal
    done : BOOL; // Input for processing completion signal
END_VAR_IN
VAR_OUT
    listen : BOOL; // Output for listening mode
END_VAR_OUT
VAR
    state : INT := 0; // State variable initialized to 0
END_VAR

// Implement state logic in the function block
IF state = 0 THEN
    IF request = FALSE THEN
        listen := TRUE; // Set listen to TRUE and remain in STATE 0
    ELSE
        listen := FALSE; // Set listen to FALSE
        state := 1; // Transition to STATE 1
        done := FALSE; // Set done to FALSE
    END_IF
ELSIF state = 1 THEN
    IF done = FALSE THEN
        // Remain in STATE 1
    ELSE
        state := 0; // Transition back to STATE 0
        listen := TRUE; // Set listen to TRUE
    END_IF
END_IF

END_FUNCTION_BLOCK