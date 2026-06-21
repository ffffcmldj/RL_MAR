ructured-text
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
    state : INT := 0; // The state variable to track the current state (0 for Idle, 1 for Processing)
END_VAR

// Main execution block
IF state = 0 THEN // Idle State
    IF request THEN
        state := 1; // Transition to Processing State
        listen := FALSE; // Set listen to FALSE when transitioning to Processing
    ELSE
        listen := TRUE; // Set listen to TRUE when no request is present
    END_IF
ELSIF state = 1 THEN // Processing State
    IF done THEN
        state := 0; // Transition back to Idle State
        listen := FALSE; // Ensure listen is FALSE in Processing state
    END_IF
END_IF

END_FUNCTION_BLOCK
END_ST