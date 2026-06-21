START_ST
FUNCTION_BLOCK FB_RequestHandler
VAR_INPUT
    request : BOOL;
    done : BOOL;
END_VAR
VAR_OUTPUT
    listen : BOOL;
END_VAR
VAR
    state : INT := 0; // 0 = LISTENING, 1 = PROCESSING
END_VAR

    // Initialize output based on current state logic
    CASE state OF
        0: // STATE 0: LISTENING (Idle)
            listen := TRUE;
            // Behavior: If request is FALSE, remain in State 0.
            // If request becomes TRUE, transition to State 1 (handled in END_CASE).
            // done remains unchanged/false as per state definition.
        1: // STATE 1: PROCESSING (Active)
            listen := FALSE;
            // Behavior: If done is FALSE, remain in State 1.
            // If done becomes TRUE, transition back to State 0 (handled in END_CASE).
    END_CASE;

    // State Transition Logic
    CASE state OF
        0:
            IF request THEN
                state := 1; // Transition to State 1
            END_IF;
        1:
            IF done THEN
                state := 0; // Transition to State 0
            END_IF;
    END_CASE;

END_FUNCTION_BLOCK
END_ST