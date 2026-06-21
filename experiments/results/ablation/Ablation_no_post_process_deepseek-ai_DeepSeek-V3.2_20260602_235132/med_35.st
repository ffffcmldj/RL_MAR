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
    i : INT; // Loop counter for multiplication loop
    COUNTER2 : INT := 0;
END_VAR

// Initialize outputs from inputs
OUTPUT_VAR1 := INPUT_VAR1;
OUTPUT_VAR2 := VAR2;

// First loop: Multiply OUTPUT_VAR1 by 2 for exactly 5 iterations
FOR i := 1 TO 5 DO
    OUTPUT_VAR1 := OUTPUT_VAR1 * 2;
END_FOR;

// Second loop: Increment OUTPUT_VAR2 by 1 for exactly 5 iterations
COUNTER2 := 0;
WHILE COUNTER2 < 5 DO
    OUTPUT_VAR2 := OUTPUT_VAR2 + 1;
    COUNTER2 := COUNTER2 + 1;
END_WHILE;

END_FUNCTION_BLOCK