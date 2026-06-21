ructured-text
START_ST
FUNCTION_BLOCK FB_RealValueAdjuster
VAR_INPUT
    x_in : REAL; // Input variable of type REAL
END_VAR

VAR_OUTPUT
    x_out : REAL; // Output variable of type REAL
END_VAR

VAR
    x : REAL; // Internal variable to hold the adjusted value
    int_x : INT; // Internal variable to hold the integer conversion of x_in
END_VAR

// Initialize the output variable
x_out := 0.0; // Initialize the output variable

// Processing logic
// Check if x_in is exactly 0.0
IF x_in = 0.0 THEN
    x := x_in + 1.0; // Add 1.0 if input is 0.0
ELSE
    x := x_in + 1.0; // Add 1.0 if input is not 0.0
END_IF;

// Convert the real input to an integer
int_x := INT(x_in);

// Check if the integer conversion is not zero
IF int_x <> 0 THEN
    x := x + 1.0; // Add 1.0 to the adjusted value if int_x is not zero
END_IF;

// Assign the final adjusted value to the output variable
x_out := x;

END_FUNCTION_BLOCK
END_ST