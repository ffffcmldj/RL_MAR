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
    // Internal constants for readability and maintainability
    InputMin : REAL := 1200.0;
    InputMax : REAL := 7000.0;
    OutputMin : REAL := 150.0;
    OutputMax : REAL := 720.0;
    
    // Pre-calculated slopes for each segment for efficiency
    Slope1 : REAL := (240.0 - 150.0) / (3600.0 - 1200.0); // 90/2400
    Slope2 : REAL := (560.0 - 240.0) / (4800.0 - 3600.0); // 320/1200
    Slope3 : REAL := (720.0 - 560.0) / (7000.0 - 4800.0); // 160/2200
END_VAR

// Main execution logic
IF InputValue < InputMin THEN
    // Below minimum range
    LinearizedValue := OutputMin;
    Error := TRUE;
    Status := 16#8001;
ELSIF InputValue > InputMax THEN
    // Above maximum range
    LinearizedValue := OutputMax;
    Error := TRUE;
    Status := 16#8001;
ELSE
    // Input is within valid range
    Error := FALSE;
    Status := 16#0000;
    
    // Determine which segment the input falls into
    IF InputValue <= 3600.0 THEN
        // Range 1: 1200 to 3600
        LinearizedValue := 150.0 + (InputValue - 1200.0) * Slope1;
    ELSIF InputValue <= 4800.0 THEN
        // Range 2: 3600 to 4800
        LinearizedValue := 240.0 + (InputValue - 3600.0) * Slope2;
    ELSE
        // Range 3: 4800 to 7000
        LinearizedValue := 560.0 + (InputValue - 4800.0) * Slope3;
    END_IF;
END_IF;

END_FUNCTION_BLOCK