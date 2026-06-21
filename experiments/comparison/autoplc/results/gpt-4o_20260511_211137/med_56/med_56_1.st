FUNCTION_BLOCK FB_SimpleRepeat
VAR_INPUT
    INPUT_VAR1 : INT := 2; // Initial value for OUTPUT_VAR1
    INPUT_COUNTER : INT := 4; // Number of iterations
END_VAR

VAR_OUTPUT
    OUTPUT_VAR1 : INT; // Final computed value after repetitions
END_VAR

VAR
    COUNTER : INT; // Loop control variable
END_VAR

// Initialization
OUTPUT_VAR1 := INPUT_VAR1;
COUNTER := INPUT_COUNTER;

// Repeat loop for multiplication
REPEAT
    OUTPUT_VAR1 := OUTPUT_VAR1 * 2; // Multiply OUTPUT_VAR1 by 2
    COUNTER := COUNTER - 1; // Decrement the counter
UNTIL COUNTER = 0
END_REPEAT

END_FUNCTION_BLOCK