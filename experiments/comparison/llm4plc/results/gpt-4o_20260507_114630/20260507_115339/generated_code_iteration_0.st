plaintext
START_ST
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
    state : INT := 0; // Current state variable
    prevState : INT := 0; // Previous state variable
END_VAR

// Main logic
IF state = 0 THEN
    // Initialization state
    prevState := state;

    IF InputValue < 1200 THEN
        state := 4; // Below minimum range
    ELSIF InputValue >= 1200 AND InputValue < 3600 THEN
        state := 1; // Range 1
    ELSIF InputValue >= 3600 AND InputValue < 4800 THEN
        state := 2; // Range 2
    ELSIF InputValue >= 4800 AND InputValue <= 7000 THEN
        state := 3; // Range 3
    ELSIF InputValue > 7000 THEN
        state := 5; // Above maximum range
    END_IF
END_IF

CASE state OF
    1: // Range 1 conversion
        LinearizedValue := 150.0 + (InputValue - 1200) * (240.0 - 150.0) / (3600.0 - 1200.0);
        Error := FALSE;
        Status := 16#0000;
        state := 0; // Return to initialization state

    2: // Range 2 conversion
        LinearizedValue := 240.0 + (InputValue - 3600) * (560.0 - 240.0) / (4800.0 - 3600.0);
        Error := FALSE;
        Status := 16#0000;
        state := 0; // Return to initialization state

    3: // Range 3 conversion
        LinearizedValue := 560.0 + (InputValue - 4800) * (720.0 - 560.0) / (7000.0 - 4800.0);
        Error := FALSE;
        Status := 16#0000;
        state := 0; // Return to initialization state

    4: // Below minimum range
        LinearizedValue := 150.0;
        Error := TRUE;
        Status := 16#8001;
        state := 0; // Return to initialization state

    5: // Above maximum range
        LinearizedValue := 720.0;
        Error := TRUE;
        Status := 16#8001;
        state := 0; // Return to initialization state

    ELSE
        // Default case, should not occur
        LinearizedValue := 0.0;
        Error := TRUE;
        Status := 16#FFFF; // Undefined state error
        state := 0; // Return to initialization state
END_CASE;

END_FUNCTION_BLOCK
END_ST