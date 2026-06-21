FUNCTION_BLOCK FB_RealValueAdjuster
VAR_INPUT
    x_in : REAL;
END_VAR

VAR_OUTPUT
    x_out : REAL;
END_VAR

VAR
    x : REAL;
    int_val : INT;
    temp_real : REAL;
END_VAR

// Initialize internal variable
x := x_in;

// Condition 1: If input is exactly 0.0, add 1.0
IF x_in = 0.0 THEN
    x := x + 1.0;
END_IF;

// Condition 2: If input is not 0.0, add 1.0
IF x_in <> 0.0 THEN
    x := x + 1.0;
END_IF;

// Condition 3: Convert to integer and check if not zero
// First, check for overflow by ensuring the value is within INT range
temp_real := x_in;
IF (temp_real >= -32768.0) AND (temp_real <= 32767.0) THEN
    // Safe conversion to integer
    int_val := REAL_TO_INT(temp_real);
    
    // If integer conversion is not zero, add 1.0 to the original real input
    IF int_val <> 0 THEN
        x := x + 1.0;
    END_IF;
ELSE
    // Handle overflow case - don't perform conversion
    // According to requirements, we should still check if x_in itself is not zero
    // for the integer conversion condition
    IF x_in <> 0.0 THEN
        x := x + 1.0;
    END_IF;
END_IF;

// Assign final result to output
x_out := x;

END_FUNCTION_BLOCK