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
    i : INT;
    tempVar1 : INT;
    tempVar2 : INT;
END_VAR

// First calculation: Multiply INPUT_VAR1 by 2 for 5 iterations
tempVar1 := INPUT_VAR1;
FOR i := 1 TO 5 DO
    tempVar1 := tempVar1 * 2;
END_FOR;
OUTPUT_VAR1 := tempVar1;

// Second calculation: Increment VAR2 by 1 for 5 iterations
tempVar2 := VAR2;
FOR i := 1 TO 5 DO
    tempVar2 := tempVar2 + 1;
END_FOR;
OUTPUT_VAR2 := tempVar2;

END_FUNCTION_BLOCK