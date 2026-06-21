FUNCTION_BLOCK FB_RealValueAdjuster
    VAR_INPUT
        x_in : REAL;
    END_VAR

    VAR_OUTPUT
        x_out : REAL;
    END_VAR

    VAR
        x : REAL;
        int_x : INT; // Variable for integer conversion
    END_VAR

    // Initialize x with the input value
    x := x_in;

    // Check if x_in is exactly 0.0
    IF x_in = 0.0 THEN
        x := x + 1.0; // Add 1.0 if x_in is 0.0
    END_IF;

    // Check if x_in is not equal to 0.0
    IF x_in <> 0.0 THEN
        x := x + 1.0; // Add 1.0 if x_in is not 0.0
    END_IF;

    // Convert x to integer
    int_x := INT(x); // Perform integer conversion using x instead of x_in

    // Check if the integer conversion is not zero
    IF int_x <> 0 THEN
        x := x + 1.0; // Add 1.0 if integer conversion is not zero
    END_IF;

    // Assign the final adjusted value to x_out
    x_out := x;

END_FUNCTION_BLOCK