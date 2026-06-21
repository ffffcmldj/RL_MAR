plaintext
START_ST
FUNCTION_BLOCK FB_Sum
VAR_INPUT
    maxValue : INT; // Specifies the maximum value for the summation loop
END_VAR

VAR_OUTPUT
    wData : WORD; // Stores the sum of integers from 0 to maxValue
END_VAR

VAR
    II : INT; // Loop index variable
    state : INT; // State variable to track the current state
    prevState : INT; // Previous state variable (optional, for debugging or tracking purposes)
END_VAR

// State Definitions
// STATE 0: INITIALIZE
// STATE 1: SUMMATION LOOP
// STATE 2: COMPLETION

// Initialization of the function block
IF state = 0 THEN
    // STATE 0: INITIALIZE
    wData := 0; // Initialize wData to 0
    II := 0; // Initialize loop index to 0
    prevState := state; // Update previous state
    state := 1; // Transition to STATE 1 (Summation Loop)
ELSIF state = 1 THEN
    // STATE 1: SUMMATION LOOP
    wData := wData + WORD(II); // Add the current value of II to wData
    II := II + 1; // Increment the loop index
    IF II > maxValue THEN
        prevState := state; // Update previous state
        state := 2; // Transition to STATE 2 (Completion)
    END_IF;
ELSIF state = 2 THEN
    // STATE 2: COMPLETION
    // No further operations; remain in this state indefinitely
    prevState := state; // Update previous state
    // wData holds the final summation result
END_IF;

END_FUNCTION_BLOCK
END_ST