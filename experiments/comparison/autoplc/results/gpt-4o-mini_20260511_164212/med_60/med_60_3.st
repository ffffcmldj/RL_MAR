FUNCTION_BLOCK FB_RequestHandler
    VAR_INPUT
        request : BOOL;
        done : BOOL;
    END_VAR_INPUT

    VAR_OUTPUT
        listen : BOOL;
    END_VAR_OUTPUT

    VAR
        state : INT := 0; // Initialize state to 0
    END_VAR

    // Main control logic
    IF state = 0 THEN
        // State 0 Logic
        IF request = FALSE THEN
            listen := TRUE; // Set listen to TRUE
        ELSE
            listen := FALSE; // Set listen to FALSE
            state := 1; // Transition to State 1
            done := FALSE; // Set done to FALSE
        END_IF
    ELSIF state = 1 THEN
        // State 1 Logic
        IF done = FALSE THEN
            // Remain in State 1
            listen := FALSE; // listen remains FALSE
        ELSE
            // Transition back to State 0
            state := 0; // Transition to State 0
            listen := TRUE; // Set listen to TRUE
        END_IF
    END_IF
END_FUNCTION_BLOCK