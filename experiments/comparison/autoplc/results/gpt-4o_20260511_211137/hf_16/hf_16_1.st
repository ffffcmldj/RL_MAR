FUNCTION_BLOCK FB_LinearizeValue
VAR_INPUT 
    InputValue : REAL; // Floating point input, raw measurement value
END_VAR

VAR_OUTPUT 
    LinearizedValue : REAL := 0.0; // Converted linear value
    Error : BOOL := FALSE; // Error status indicator
    Status : WORD := 16#0000; // Status code
END_VAR

VAR 
    // No additional variables needed here
END_VAR

// Implementation of the piecewise linear conversion
IF InputValue < 1200.0 THEN
    // Below minimum range
    LinearizedValue := 150.0;
    Error := TRUE;
    Status := 16#8001;
ELSIF InputValue <= 3600.0 THEN
    // Range 1: 1200 to 3600
    LinearizedValue := 150.0 + (InputValue - 1200.0) * (240.0 - 150.0) / (3600.0 - 1200.0);
    Error := FALSE;
    Status := 16#0000;
ELSIF InputValue <= 4800.0 THEN
    // Range 2: 3600 to 4800
    LinearizedValue := 240.0 + (InputValue - 3600.0) * (560.0 - 240.0) / (4800.0 - 3600.0);
    Error := FALSE;
    Status := 16#0000;
ELSIF InputValue <= 7000.0 THEN
    // Range 3: 4800 to 7000
    LinearizedValue := 560.0 + (InputValue - 4800.0) * (720.0 - 560.0) / (7000.0 - 4800.0);
    Error := FALSE;
    Status := 16#0000;
ELSE
    // Above maximum range
    LinearizedValue := 720.0;
    Error := TRUE;
    Status := 16#8001;
END_IF

END_FUNCTION_BLOCK