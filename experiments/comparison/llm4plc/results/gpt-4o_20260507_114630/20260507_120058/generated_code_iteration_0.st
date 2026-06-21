scl
START_ST
FUNCTION_BLOCK FB_RealValueAdjuster
VAR_INPUT
    x_in : REAL; // Input variable of type real
END_VAR

VAR_OUTPUT
    x_out : REAL; // Output variable of type real
END_VAR

VAR
    x : REAL; // Temporary variable for intermediate calculations
    x_int : INT; // Temporary variable for integer conversion
END_VAR

// Initialize x with the value of x_in
x := x_in;

// Check if x_in is exactly 0.0
IF x_in = 0.0 THEN
    x := x + 1.0; // Add 1.0 to x
END_IF;

// Check if x_in is not 0.0
IF x_in <> 0.0 THEN
    x := x + 1.0; // Add 1.0 to x
END_IF;

// Convert x_in to an integer
x_int := REAL_TO_INT(x_in);

// Check if the integer conversion is not zero
IF x_int <> 0 THEN
    x := x + 1.0; // Add an additional 1.0 to x
END_IF;

// Assign the final result to x_out
x_out := x;

END_FUNCTION_BLOCK
END_ST