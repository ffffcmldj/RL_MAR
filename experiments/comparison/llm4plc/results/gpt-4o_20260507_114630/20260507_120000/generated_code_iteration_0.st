plaintext
START_ST

FUNCTION_BLOCK FB_SimpleCalculation
VAR_INPUT
    INPUT_VAR1 : INT := 2; // Input variable initialized to 2
    VAR2 : INT := 0;      // Input variable for the increment loop
END_VAR

VAR_OUTPUT
    OUTPUT_VAR1 : INT;    // Output variable to store the result of the multiplication loop
    OUTPUT_VAR2 : INT;    // Output variable to store the result of the increment loop
END_VAR

VAR
    state : INT := 0;     // State variable to track the current state of the FSM
    counter1 : INT := 0;  // Counter for the multiplication loop
    counter2 : INT := 0;  // Counter for the increment loop
END_VAR

// Main logic
CASE state OF
    // STATE 0: INITIALIZE
    0:
        OUTPUT_VAR1 := INPUT_VAR1; // Initialize OUTPUT_VAR1 to INPUT_VAR1
        OUTPUT_VAR2 := VAR2;       // Initialize OUTPUT_VAR2 to VAR2
        counter1 := 0;             // Reset counter1 to 0
        counter2 := 0;             // Reset counter2 to 0
        state := 1;                // Transition to STATE 1

    // STATE 1: MULTIPLICATION LOOP
    1:
        OUTPUT_VAR1 := OUTPUT_VAR1 * 2; // Multiply OUTPUT_VAR1 by 2
        counter1 := counter1 + 1;       // Increment counter1 by 1
        IF counter1 >= 5 THEN           // Check if 5 iterations are complete
            state := 2;                 // Transition to STATE 2
        END_IF

    // STATE 2: INCREMENT LOOP
    2:
        OUTPUT_VAR2 := OUTPUT_VAR2 + 1; // Increment OUTPUT_VAR2 by 1
        counter2 := counter2 + 1;       // Increment counter2 by 1
        IF counter2 >= 5 THEN           // Check if 5 iterations are complete
            state := 3;                 // Transition to STATE 3
        END_IF

    // STATE 3: FINALIZE
    3:
        // Hold the final values of OUTPUT_VAR1 and OUTPUT_VAR2
        // No further transitions occur
END_CASE

END_FUNCTION_BLOCK

END_ST