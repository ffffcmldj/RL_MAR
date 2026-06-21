ructured-text
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
    state : INT; // The state variable to track the current state
END_VAR

// State Definitions
state := 0; // Initialize state

// State Machine Logic
CASE state OF
    0: // INITIALIZE
        LinearizedValue := 0.0;
        Error := FALSE;
        Status := 16#0000;
        
        IF InputValue < 1200 THEN
            state := 1; // HANDLE_OUT_OF_RANGE_LOW
        ELSIF InputValue > 7000 THEN
            state := 2; // HANDLE_OUT_OF_RANGE_HIGH
        ELSIF InputValue >= 1200 AND InputValue < 3600 THEN
            state := 3; // CONVERT_RANGE_1
        ELSIF InputValue >= 3600 AND InputValue < 4800 THEN
            state := 4; // CONVERT_RANGE_2
        ELSIF InputValue >= 4800 AND InputValue <= 7000 THEN
            state := 5; // CONVERT_RANGE_3
        END_IF;

    1: // HANDLE_OUT_OF_RANGE_LOW
        LinearizedValue := 150.0;
        Error := TRUE;
        Status := 16#8001;
        // Transition to success state
        state := 6; // SUCCESS

    2: // HANDLE_OUT_OF_RANGE_HIGH
        LinearizedValue := 720.0;
        Error := TRUE;
        Status := 16#8001;
        // Transition to success state
        state := 6; // SUCCESS

    3: // CONVERT_RANGE_1
        LinearizedValue := 150.0 + (InputValue - 1200) * (240 - 150) / (3600 - 1200);
        Error := FALSE;
        Status := 16#0000;
        // Transition to success state
        state := 6; // SUCCESS

    4: // CONVERT_RANGE_2
        LinearizedValue := 240.0 + (InputValue - 3600) * (560 - 240) / (4800 - 3600);
        Error := FALSE;
        Status := 16#0000;
        // Transition to success state
        state := 6; // SUCCESS

    5: // CONVERT_RANGE_3
        LinearizedValue := 560.0 + (InputValue - 4800) * (720 - 560) / (7000 - 4800);
        Error := FALSE;
        Status := 16#0000;
        // Transition to success state
        state := 6; // SUCCESS

    6: // SUCCESS
        // Final state, do nothing
        // The output values have already been set in previous states
END_CASE;

END_FUNCTION_BLOCK
END_ST