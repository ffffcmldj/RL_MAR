FUNCTION_BLOCK FB_RealValueAdjuster
VAR_INPUT
    x_in : REAL;
END_VAR
VAR_OUTPUT
    x_out : REAL;
END_VAR
VAR
    x_temp : REAL;
    int_val : INT;
END_VAR

// Initialize with input value
x_temp := x_in;

// First condition: if input is exactly 0.0, add 1.0
IF x_in = 0.0 THEN
    x_temp := x_temp + 1.0;
END_IF;

// Second condition: if input is not 0.0, also add 1.0
IF x_in <> 0.0 THEN
    x_temp := x_temp + 1.0;
END_IF;

// Third condition: convert to integer and check
int_val := REAL_TO_INT(x_in);
IF int_val <> 0 THEN
    x_temp := x_temp + 1.0;
END_IF;

// Assign final result to output
x_out := x_temp;

END_FUNCTION_BLOCK