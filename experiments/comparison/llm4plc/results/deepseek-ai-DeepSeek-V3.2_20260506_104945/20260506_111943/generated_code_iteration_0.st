START_ST
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
    // No persistent internal variables needed
END_VAR

    // Main execution logic
    IF InputValue < 1200.0 THEN
        // Below minimum range
        LinearizedValue := 150.0;
        Error := TRUE;
        Status := 16#8001;
    ELSIF InputValue > 7000.0 THEN
        // Above maximum range
        LinearizedValue := 720.0;
        Error := TRUE;
        Status := 16#8001;
    ELSE
        // Valid range - determine segment
        Error := FALSE;
        Status := 16#0000;
        
        IF (InputValue >= 1200.0) AND (InputValue < 3600.0) THEN
            // Range 1: Input 1200 to 3600, Output 150 to 240
            LinearizedValue := 150.0 + (InputValue - 1200.0) * (240.0 - 150.0) / (3600.0 - 1200.0);
        ELSIF (InputValue >= 3600.0) AND (InputValue < 4800.0) THEN
            // Range 2: Input 3600 to 4800, Output 240 to 560
            LinearizedValue := 240.0 + (InputValue - 3600.0) * (560.0 - 240.0) / (4800.0 - 3600.0);
        ELSE
            // Range 3: Input 4800 to 7000, Output 560 to 720
            LinearizedValue := 560.0 + (InputValue - 4800.0) * (720.0 - 560.0) / (7000.0 - 4800.0);
        END_IF;
    END_IF;

END_FUNCTION_BLOCK
END_ST