FUNCTION_BLOCK FB_RequestHandler
    VAR_INPUT
        request : BOOL;
        done : BOOL;
    END_VAR_INPUT

    VAR_OUTPUT
        listen : BOOL;
    END_VAR

    VAR
        state : INT := 0; // Initial state is 0
    END_VAR

    // Main control logic
    IF state = 0 THEN
        // State 0: Listening State
        IF request = FALSE THEN
            listen := TRUE; // Remain in listening mode
        ELSE
            listen := FALSE; // Stop listening
            state := 1; // Transition to State 1
            // Assume done is set to FALSE externally when transitioning
        END_IF
    ELSIF state = 1 THEN
        // State 1: Processing State
        IF done = TRUE THEN
            state := 0; // Transition back to State 0
            listen := TRUE; // Start listening again
        END_IF
        // If done is FALSE, remain in State 1
    END_IF
END_FUNCTION_BLOCK