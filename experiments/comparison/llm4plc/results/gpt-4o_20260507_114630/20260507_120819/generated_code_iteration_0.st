pascal
START_ST

FUNCTION_BLOCK StateMachineControl
VAR_INPUT
    request : BOOL; // Input signal to request transition to the Processing state
    done : BOOL;    // Input signal to request transition back to the Idle state
END_VAR

VAR_OUTPUT
    listen : BOOL;  // Output signal that is TRUE only in the Idle state
END_VAR

VAR
    state : INT := 0; // The state variable to track the current state (0 = Idle, 1 = Processing)
END_VAR

// State Machine Logic
IF state = 0 THEN // State 0: Idle
    listen := TRUE; // Set listen to TRUE in Idle state
    IF request THEN
        state := 1; // Transition to State 1: Processing when request is TRUE
    END_IF;
ELSIF state = 1 THEN // State 1: Processing
    listen := FALSE; // Set listen to FALSE in Processing state
    IF done THEN
        state := 0; // Transition back to State 0: Idle when done is TRUE
    END_IF;
END_IF;

END_FUNCTION_BLOCK

END_ST