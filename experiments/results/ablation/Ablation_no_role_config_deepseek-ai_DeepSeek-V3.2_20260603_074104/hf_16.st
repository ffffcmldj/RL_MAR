FUNCTION_BLOCK FB_LinearizeValue
VAR_INPUT
    InputValue : REAL;                    // Raw input value for conversion
END_VAR
VAR_OUTPUT
    LinearizedValue : REAL := 0.0;        // Converted output value
    Error : BOOL := FALSE;                // Error status flag
    Status : WORD := 16#0000;             // Operation status code
END_VAR
VAR
    // No additional variables needed
END_VAR

// Main execution logic
IF InputValue < 1200.0 THEN
    // Below minimum range (InputValue < 1200)
    LinearizedValue := 150.0;
    Error := TRUE;
    Status := 16#8001;
ELSIF InputValue >= 1200.0 AND InputValue < 3600.0 THEN
    // Range 1: Input 1200 to 3600 -> Output 150 to 240
    LinearizedValue := 150.0 + (InputValue - 1200.0) * (240.0 - 150.0) / (3600.0 - 1200.0);
    Error := FALSE;
    Status := 16#0000;
ELSIF InputValue >= 3600.0 AND InputValue < 4800.0 THEN
    // Range 2: Input 3600 to 4800 -> Output 240 to 560
    LinearizedValue := 240.0 + (InputValue - 3600.0) * (560.0 - 240.0) / (4800.0 - 3600.0);
    Error := FALSE;
    Status := 16#0000;
ELSIF InputValue >= 4800.0 AND InputValue <= 7000.0 THEN
    // Range 3: Input 4800 to 7000 -> Output 560 to 720
    LinearizedValue := 560.0 + (InputValue - 4800.0) * (720.0 - 560.0) / (7000.0 - 4800.0);
    Error := FALSE;
    Status := 16#0000;
ELSE
    // Above maximum range (InputValue > 7000)
    LinearizedValue := 720.0;
    Error := TRUE;
    Status := 16#8001;
END_IF;

END_FUNCTION_BLOCK