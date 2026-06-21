plaintext
START_ST
FUNCTION_BLOCK FB_SimpleRepeat
VAR_INPUT
    INPUT_VAR1 : INT := 2; // Initial value
    INPUT_COUNTER : INT := 4; // Number of iterations
END_VAR

VAR_OUTPUT
    OUTPUT_VAR1 : INT; // Final computed value
END_VAR

VAR
    state : INT := 0; // State variable
    COUNTER : INT; // Internal variable to track remaining iterations
END_VAR

// Function block logic
CASE state OF
    // STATE 0: INITIALIZE
    0:
        OUTPUT_VAR1 := INPUT_VAR1; // Initialize OUTPUT_VAR1 with INPUT_VAR1
        COUNTER := INPUT_COUNTER; // Initialize COUNTER with INPUT_COUNTER
        state := 1; // Transition to STATE 1

    // STATE 1: MULTIPLY AND DECREMENT COUNTER
    1:
        OUTPUT_VAR1 := OUTPUT_VAR1 * 2; // Multiply OUTPUT_VAR1 by 2
        COUNTER := COUNTER - 1; // Decrement COUNTER by 1
        IF COUNTER > 0 THEN
            state := 1; // Remain in STATE 1 if COUNTER > 0
        ELSE
            state := 2; // Transition to STATE 2 if COUNTER = 0
        END_IF;

    // STATE 2: TERMINATE
    2:
        // No further operations, remain in this state indefinitely
        state := 2; // Stay in STATE 2
END_CASE;

END_FUNCTION_BLOCK
END_ST