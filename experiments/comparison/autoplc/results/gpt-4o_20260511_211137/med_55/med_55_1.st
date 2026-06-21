FUNCTION_BLOCK StateMachineControl
VAR_INPUT
    request : BOOL;
    done : BOOL;
END_VAR

VAR_OUTPUT
    listen : BOOL;
END_VAR

VAR
    state : INT := 0; // 0 for Idle, 1 for Processing
END_VAR

// Main logic for state machine control
IF state = 0 THEN
    // Idle State
    listen := TRUE; // Set listen to TRUE in Idle state
    IF request THEN
        // Transition from Idle to Processing
        state := 1;
    END_IF
ELSIF state = 1 THEN
    // Processing State
    listen := FALSE; // Set listen to FALSE in Processing state
    IF done THEN
        // Transition from Processing to Idle
        state := 0;
    END_IF
END_IF

END_FUNCTION_BLOCK