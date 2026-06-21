FUNCTION_BLOCK FB_LinearizeValue
VAR_INPUT 
    InputValue : REAL; // Floating point input, raw measurement value
END_VAR

VAR_OUTPUT 
    LinearizedValue : REAL; // Converted linear value
    Error : BOOL; // Error status indicator
    Status : WORD; // Status code
END_VAR

VAR
    // No additional variables needed here
END_VAR

// Main execution method
METHOD Execute
    // Initialization
    LinearizedValue := 0.0;
    Error := FALSE;
    Status := 16#0000;

    // Range Checking and Conversion
    IF InputValue < 1200.0 THEN
        LinearizedValue := 150.0;
        Error := TRUE;
        Status := 16#8001; // Out of range
    ELSIF InputValue > 7000.0 THEN
        LinearizedValue := 720.0;
        Error := TRUE;
        Status := 16#8001; // Out of range
    ELSE
        // Normal Operation
        IF InputValue >= 1200.0 AND InputValue <= 3600.0 THEN
            LinearizedValue := 150.0 + (InputValue - 1200.0) * (240.0 - 150.0) / (3600.0 - 1200.0);
        ELSIF InputValue > 3600.0 AND InputValue <= 4800.0 THEN
            LinearizedValue := 240.0 + (InputValue - 3600.0) * (560.0 - 240.0) / (4800.0 - 3600.0);
        ELSIF InputValue > 4800.0 AND InputValue <= 7000.0 THEN
            LinearizedValue := 560.0 + (InputValue - 4800.0) * (720.0 - 560.0) / (7000.0 - 4800.0);
        END_IF;
        
        Error := FALSE;
        Status := 16#0000; // Successful conversion
    END_IF;
END_METHOD

END_FUNCTION_BLOCK