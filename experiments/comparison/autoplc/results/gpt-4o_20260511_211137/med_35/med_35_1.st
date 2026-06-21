FUNCTION_BLOCK FB_SimpleCalculation
    VAR_INPUT
        INPUT_VAR1 : INT := 2;
        VAR2 : INT := 0;
    END_VAR

    VAR_OUTPUT
        OUTPUT_VAR1 : INT;
        OUTPUT_VAR2 : INT;
    END_VAR

    VAR
        COUNTER2 : INT := 0;
        i : INT;
    END_VAR

    // Assign INPUT_VAR1 to OUTPUT_VAR1
    OUTPUT_VAR1 := INPUT_VAR1;

    // First Calculation Loop: Multiply OUTPUT_VAR1 by 2 for 5 iterations
    FOR i := 1 TO 5 DO
        OUTPUT_VAR1 := OUTPUT_VAR1 * 2;
    END_FOR

    // Assign VAR2 to OUTPUT_VAR2
    OUTPUT_VAR2 := VAR2;

    // Second Calculation Loop: Increment VAR2 by 1 for 5 iterations
    FOR i := 1 TO 5 DO
        VAR2 := VAR2 + 1;
    END_FOR

    // Assign the final value of VAR2 to OUTPUT_VAR2
    OUTPUT_VAR2 := VAR2;

END_FUNCTION_BLOCK