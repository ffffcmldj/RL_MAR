FUNCTION_BLOCK StateMachineControl
VAR_INPUT
    request : BOOL;
    done : BOOL;
END_VAR

VAR_OUTPUT
    listen : BOOL;
END_VAR

VAR
    state : INT := 0; // 0 = Idle, 1 = Processing
END_VAR

// Main execution logic
IF state = 0 THEN // Idle State
    IF request THEN
        state := 1; // Transition to Processing
        listen := FALSE; // Listen should be FALSE in Processing state
    ELSE
        listen := TRUE; // Listen should be TRUE when Idle and no request
    END_IF
ELSIF state = 1 THEN // Processing State
    IF done THEN
        state := 0; // Transition back to Idle
    END_IF
END_IF

END_FUNCTION_BLOCK