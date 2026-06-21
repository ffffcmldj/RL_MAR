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
    loop_index1 : INT;
    loop_index2 : INT;
END_VAR

// First loop: Multiply OUTPUT_VAR1 by 2 for 5 iterations
OUTPUT_VAR1 := INPUT_VAR1;
FOR loop_index1 := 1 TO 5 BY 1 DO
    OUTPUT_VAR1 := OUTPUT_VAR1 * 2;
END_FOR;

// Second loop: Increment OUTPUT_VAR2 by 1 for 5 iterations
OUTPUT_VAR2 := VAR2;
FOR loop_index2 := 1 TO 5 BY 1 DO
    OUTPUT_VAR2 := OUTPUT_VAR2 + 1;
END_FOR;

// Update COUNTER2 (though not used in calculation, maintained for compatibility)
COUNTER2 := COUNTER2 + 1;
END_FUNCTION_BLOCK