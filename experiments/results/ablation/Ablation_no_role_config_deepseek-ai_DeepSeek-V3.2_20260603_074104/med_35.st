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
    LoopIndex : INT;
END_VAR

// Initialization
OUTPUT_VAR1 := INPUT_VAR1;
OUTPUT_VAR2 := VAR2;

// First loop: Multiply OUTPUT_VAR1 by 2 for 5 iterations
FOR LoopIndex := 1 TO 5 DO
    OUTPUT_VAR1 := OUTPUT_VAR1 * 2;
END_FOR;

// Second loop: Increment OUTPUT_VAR2 by 1 for 5 iterations
// Using WHILE loop with COUNTER2 as specified
COUNTER2 := 0;
WHILE COUNTER2 < 5 DO
    OUTPUT_VAR2 := OUTPUT_VAR2 + 1;
    COUNTER2 := COUNTER2 + 1;
END_WHILE;

END_FUNCTION_BLOCK