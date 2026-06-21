FUNCTION_BLOCK FB_SimpleCalculation
    VAR_INPUT
        INPUT_VAR1 : INT := 2; // Initialize INPUT_VAR1 to 2
    END_VAR

    VAR_OUTPUT
        OUTPUT_VAR1 : INT; // Output for multiplication result
        OUTPUT_VAR2 : INT; // Output for iteration count
    END_VAR

    VAR
        COUNTER1 : INT := 0; // Loop counter for multiplication
        COUNTER2 : INT := 0; // Loop counter for incrementing VAR2
        VAR2 : INT := 0; // Declare VAR2 as an INT variable
    END_VAR

    // First Calculation Loop
    OUTPUT_VAR1 := INPUT_VAR1; // Assign initial value to OUTPUT_VAR1
    FOR COUNTER1 := 1 TO 5 DO
        OUTPUT_VAR1 := OUTPUT_VAR1 * 2; // Multiply OUTPUT_VAR1 by 2 for 5 iterations
    END_FOR

    // Second Calculation Loop
    VAR2 := 0; // Initialize VAR2 to 0
    FOR COUNTER2 := 1 TO 5 DO
        VAR2 := VAR2 + 1; // Increment VAR2 by 1 for 5 iterations
    END_FOR

    OUTPUT_VAR2 := VAR2; // Assign final value of VAR2 to OUTPUT_VAR2
END_FUNCTION_BLOCK