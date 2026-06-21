plaintext
START_ST
FUNCTION_BLOCK FB_RequestHandler
VAR_INPUT
    request : BOOL; // Input: Indicates if a request has been made
    done : BOOL;    // Input: Indicates if the processing is completed
END_VAR
VAR_OUTPUT
    listen : BOOL;  // Output: Indicates whether the system is in listening mode
END_VAR
VAR
    state : INT := 0; // Internal variable to track the current state of the system
END_VAR

// Main logic for the finite state machine
IF state = 0 THEN
    // STATE 0: Listening State
    IF request = FALSE THEN
        listen := TRUE; // Remain in listening mode
    ELSIF request = TRUE THEN
        listen := FALSE; // Stop listening
        state := 1;      // Transition to STATE 1
    END_IF;
ELSIF state = 1 THEN
    // STATE 1: Processing State
    IF done = FALSE THEN
        // Remain in STATE 1, no changes to outputs
    ELSIF done = TRUE THEN
        listen := TRUE; // Transition back to listening mode
        state := 0;     // Transition to STATE 0
    END_IF;
END_IF;

END_FUNCTION_BLOCK
END_ST