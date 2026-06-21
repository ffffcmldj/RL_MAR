FUNCTION_BLOCK FB_RealValueAdjuster
    VAR_INPUT
        x_in : REAL;
    END_VAR

    VAR_OUTPUT
        x_out : REAL;
    END_VAR

    VAR
        x : REAL;
        int_conversion : INT;
    END_VAR

    // Initialize x with the input value
    x := x_in;

    // Conditional processing: Add 1.0 to x regardless of its value
    IF x = 0.0 THEN
        x := x + 1.0;
    ELSE
        x := x + 1.0;
    END_IF

    // Convert real input to integer
    int_conversion := REAL_TO_INT(x_in);

    // If integer conversion is not zero, add 1.0 to the original real input
    IF int_conversion <> 0 THEN
        x := x + 1.0;
    END_IF

    // Assign the final adjusted value to the output variable
    x_out := x;
END_FUNCTION_BLOCK