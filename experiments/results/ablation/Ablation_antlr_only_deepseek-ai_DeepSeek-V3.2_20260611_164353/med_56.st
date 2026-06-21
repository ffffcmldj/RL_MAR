FUNCTION_BLOCK FB_SimpleRepeat
VAR_INPUT
    INPUT_VAR1 : INT := 2;
    INPUT_COUNTER : INT := 4;
END_VAR

VAR_OUTPUT
    OUTPUT_VAR1 : INT;
END_VAR

VAR
    WORK_COUNTER : INT;
END_VAR

// Initialize output with input value
OUTPUT_VAR1 := INPUT_VAR1;

// Initialize working counter
WORK_COUNTER := INPUT_COUNTER;

// Loop until counter reaches zero
WHILE WORK_COUNTER > 0 DO
    // Double the output value
    OUTPUT_VAR1 := OUTPUT_VAR1 * 2;
    
    // Decrement counter
    WORK_COUNTER := WORK_COUNTER - 1;
END_WHILE;

END_FUNCTION_BLOCK