ructured-text
FUNCTION_BLOCK FB_SplitNumber
VAR_INPUT 
    InputNumber : INT; 
END_VAR

VAR_OUTPUT 
    Thousands : INT;
    Hundreds : INT;
    Tens : INT;
    Ones : INT;
    Min : INT;
    error : BOOL; 
    status : WORD; 
END_VAR

VAR 
    state : INT; // THE STATE VARIABLE
    prevState : INT; // THE PREVIOUS STATE VARIABLE
    tempNumber : INT; // Temporary variable for processing
    minValue : INT; // Variable to track the minimum non-zero digit
END_VAR

// Initialize state
state := 0;
error := FALSE;
status := 16#0000;
Thousands := 0;
Hundreds := 0;
Tens := 0;
Ones := 0;
Min := 0;

CASE state OF
    0: // STATE 0: INITIALIZE
        // Always transition to validate input
        state := 1;

    1: // STATE 1: VALIDATE INPUT
        IF InputNumber < 0 OR InputNumber > 9999 THEN
            error := TRUE;
            status := 16#8001;
            Thousands := 0;
            Hundreds := 0;
            Tens := 0;
            Ones := 0;
            Min := 0;
            state := 4; // Transition to ERROR HANDLING
        ELSE
            error := FALSE;
            status := 16#0000;
            state := 2; // Transition to SEPARATE DIGITS
        END_IF;

    2: // STATE 2: SEPARATE DIGITS
        Thousands := InputNumber / 1000;
        Hundreds := (InputNumber MOD 1000) / 100;
        Tens := (InputNumber MOD 100) / 10;
        Ones := InputNumber MOD 10;
        Min := 0; // Initialize Min
        state := 3; // Transition to FIND MINIMUM NON-ZERO DIGIT

    3: // STATE 3: FIND MINIMUM NON-ZERO DIGIT
        minValue := 32767; // Initialize minValue to maximum possible INT value
        
        // Compare non-zero digits
        IF Thousands > 0 THEN
            minValue := minimal(minValue, Thousands);
        END_IF;
        
        IF Hundreds > 0 THEN
            minValue := minimal(minValue, Hundreds);
        END_IF;
        
        IF Tens > 0 THEN
            minValue := minimal(minValue, Tens);
        END_IF;
        
        IF Ones > 0 THEN
            minValue := minimal(minValue, Ones);
        END_IF;

        // Set Min based on minValue
        IF minValue = 32767 THEN
            Min := 0; // All digits were zero
        ELSE
            Min := minValue; // Found minimum non-zero digit
        END_IF;

        state := 0; // Transition back to INITIALIZE

    4: // STATE 4: ERROR HANDLING
        // Error state already handled in STATE 1
        state := 0; // Transition back to INITIALIZE
END_CASE;

END_FUNCTION_BLOCK