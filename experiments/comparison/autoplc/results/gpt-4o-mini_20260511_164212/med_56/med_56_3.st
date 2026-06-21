FUNCTION_BLOCK FB_SimpleRepeat
    VAR_INPUT
        INPUT_VAR1 : INT := 2; // Initial value
        INPUT_COUNTER : INT := 4; // Number of iterations
    END_VAR

    VAR_OUTPUT
        OUTPUT_VAR1 : INT; // Final computed value
    END_VAR

    VAR
        COUNTER : INT; // Loop control variable
    END_VAR

    // Initialize OUTPUT_VAR1 with INPUT_VAR1
    OUTPUT_VAR1 := INPUT_VAR1;

    // REPEAT loop to multiply OUTPUT_VAR1 by 2 for INPUT_COUNTER iterations
    REPEAT
        OUTPUT_VAR1 := OUTPUT_VAR1 * 2; // Multiply OUTPUT_VAR1 by 2
        INPUT_COUNTER := INPUT_COUNTER - 1; // Decrement INPUT_COUNTER
    UNTIL INPUT_COUNTER = 0; // Loop terminates when INPUT_COUNTER equals 0
END_REPEAT // Properly close the REPEAT loop without a semicolon
END_FUNCTION_BLOCK; // Properly terminate the function block with a semicolon