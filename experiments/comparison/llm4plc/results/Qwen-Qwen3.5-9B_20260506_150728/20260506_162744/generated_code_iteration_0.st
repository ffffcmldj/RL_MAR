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
// No additional variables needed here
END_VAR

// Conditional evaluation state logic within a single scan cycle
IF InputValue < 1200.0 THEN
    // STATE 0: OUT_OF_RANGE_LOW
    LinearizedValue := 150.0;
    Error := TRUE;
    Status := 16#8001;
ELSIF InputValue <= 3600.0 THEN
    // STATE 1: RANGE_1 (1200 <= InputValue <= 3600)
    // Formula: 150.0 + (InputValue - 1200) * (240 - 150) / (3600 - 1200)
    // Simplified: 150.0 + (InputValue - 1200) * 90 / 2400
    LinearizedValue := 150.0 + (InputValue - 1200.0) * 90.0 / 2400.0;
    Error := FALSE;
    Status := 16#0000;
ELSIF InputValue <= 4800.0 THEN
    // STATE 2: RANGE_2 (3600 < InputValue <= 4800)
    // Formula: 240.0 + (InputValue - 3600) * (560 - 240) / (4800 - 3600)
    // Simplified: 240.0 + (InputValue - 3600) * 320 / 1200
    LinearizedValue := 240.0 + (InputValue - 3600.0) * 320.0 / 1200.0;
    Error := FALSE;
    Status := 16#0000;
ELSIF InputValue <= 7000.0 THEN
    // STATE 3: RANGE_3 (4800 < InputValue <= 7000)
    // Formula: 560.0 + (InputValue - 4800) * (720 - 560) / (7000 - 4800)
    // Simplified: 560.0 + (InputValue - 4800) * 160 / 2200
    LinearizedValue := 560.0 + (InputValue - 4800.0) * 160.0 / 2200.0;
    Error := FALSE;
    Status := 16#0000;
ELSE
    // STATE 4: OUT_OF_RANGE_HIGH (InputValue > 7000)
    LinearizedValue := 720.0;
    Error := TRUE;
    Status := 16#8001;
END_IF

END_FUNCTION_BLOCK
END_ST