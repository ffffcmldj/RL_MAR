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
    // Internal constants for the piecewise linear segments
    RANGE1_IN_MIN : REAL := 1200.0;
    RANGE1_IN_MAX : REAL := 3600.0;
    RANGE1_OUT_MIN : REAL := 150.0;
    RANGE1_OUT_MAX : REAL := 240.0;
    
    RANGE2_IN_MIN : REAL := 3600.0;
    RANGE2_IN_MAX : REAL := 4800.0;
    RANGE2_OUT_MIN : REAL := 240.0;
    RANGE2_OUT_MAX : REAL := 560.0;
    
    RANGE3_IN_MIN : REAL := 4800.0;
    RANGE3_IN_MAX : REAL := 7000.0;
    RANGE3_OUT_MIN : REAL := 560.0;
    RANGE3_OUT_MAX : REAL := 720.0;
    
    // Status codes
    STATUS_SUCCESS : WORD := 16#0000;
    STATUS_OUT_OF_RANGE : WORD := 16#8001;
END_VAR

// Main execution logic
IF InputValue < RANGE1_IN_MIN THEN
    // Below minimum range
    LinearizedValue := RANGE1_OUT_MIN;
    Error := TRUE;
    Status := STATUS_OUT_OF_RANGE;
ELSIF InputValue >= RANGE1_IN_MIN AND InputValue <= RANGE1_IN_MAX THEN
    // Range 1: 1200 to 3600
    LinearizedValue := RANGE1_OUT_MIN + (InputValue - RANGE1_IN_MIN) * 
                      (RANGE1_OUT_MAX - RANGE1_OUT_MIN) / 
                      (RANGE1_IN_MAX - RANGE1_IN_MIN);
    Error := FALSE;
    Status := STATUS_SUCCESS;
ELSIF InputValue > RANGE1_IN_MAX AND InputValue <= RANGE2_IN_MAX THEN
    // Range 2: 3600 to 4800
    LinearizedValue := RANGE2_OUT_MIN + (InputValue - RANGE2_IN_MIN) * 
                      (RANGE2_OUT_MAX - RANGE2_OUT_MIN) / 
                      (RANGE2_IN_MAX - RANGE2_IN_MIN);
    Error := FALSE;
    Status := STATUS_SUCCESS;
ELSIF InputValue > RANGE2_IN_MAX AND InputValue <= RANGE3_IN_MAX THEN
    // Range 3: 4800 to 7000
    LinearizedValue := RANGE3_OUT_MIN + (InputValue - RANGE3_IN_MIN) * 
                      (RANGE3_OUT_MAX - RANGE3_OUT_MIN) / 
                      (RANGE3_IN_MAX - RANGE3_IN_MIN);
    Error := FALSE;
    Status := STATUS_SUCCESS;
ELSE
    // Above maximum range
    LinearizedValue := RANGE3_OUT_MAX;
    Error := TRUE;
    Status := STATUS_OUT_OF_RANGE;
END_IF;

END_FUNCTION_BLOCK