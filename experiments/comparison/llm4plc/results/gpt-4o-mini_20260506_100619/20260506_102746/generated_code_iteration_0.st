ructured-text
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
    COUNTER : INT; // Counter for iterations
    state : INT; // The state variable
END_VAR

// Logic Implementation
state := 0; // Initialize state

REPEAT
    CASE state OF
        0: // STATE 0: INITIALIZE
            OUTPUT_VAR1 := INPUT_VAR1; // Initialize OUTPUT_VAR1
            COUNTER := INPUT_COUNTER; // Set COUNTER to INPUT_COUNTER
            IF COUNTER > 0 THEN
                state := 1; // Transition to STATE 1
            END_IF;

        1: // STATE 1: REPEAT MULTIPLICATION
            OUTPUT_VAR1 := OUTPUT_VAR1 * 2; // Multiply OUTPUT_VAR1 by 2
            COUNTER := COUNTER - 1; // Decrement COUNTER
            IF COUNTER > 0 THEN
                state := 1; // Stay in STATE 1
            ELSE
                state := 0; // Transition back to STATE 0
            END_IF;
    END_CASE;
UNTIL state = 0; // Loop until state is 0
END_FUNCTION_BLOCK
END_ST