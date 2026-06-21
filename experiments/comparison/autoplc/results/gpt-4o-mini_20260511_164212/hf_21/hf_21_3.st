FUNCTION_BLOCK FB_SplitNumber
VAR_INPUT 
    InputNumber : INT; 
END_VAR

VAR_OUTPUT 
    Thousands : INT;
    Hundreds : INT;
    Tens : INT;
    Ones : INT;
    MinValue : INT; // Renamed to avoid conflict with function name
    error : BOOL; 
    status : WORD; 
END_VAR

VAR 
    tempNumber : INT; 
    minValue : INT;
    digit : INT;
    i : INT; // Loop variable for digit checking
END_VAR

// Input Validation
IF InputNumber < 0 OR InputNumber > 9999 THEN
    error := TRUE;
    status := 16#8001;
    Thousands := 0;
    Hundreds := 0;
    Tens := 0;
    Ones := 0;
    MinValue := 0; // Updated to match new variable name
ELSE
    error := FALSE;
    status := 0;

    // Digit Separation Logic
    Thousands := InputNumber / 1000;
    tempNumber := InputNumber MOD 1000;
    Hundreds := tempNumber / 100;
    tempNumber := tempNumber MOD 100;
    Tens := tempNumber / 10;
    Ones := tempNumber MOD 10;

    // Minimum Value Detection
    minValue := 32767; // Initialize to maximum possible INT value

    // Check each digit for minimum non-zero value
    FOR i := 1 TO 4 DO
        CASE i OF
            1: digit := Thousands;
            2: digit := Hundreds;
            3: digit := Tens;
            4: digit := Ones;
        END_CASE;

        IF digit <> 0 THEN
            minValue := minimal(digit, minValue); // Corrected function call
        END_IF;
    END_FOR;

    // Set Min output based on minValue
    IF minValue = 32767 THEN
        MinValue := 0; // Updated to match new variable name
    ELSE
        MinValue := minValue; // Found a non-zero minimum
    END_IF;
END_IF;

END_FUNCTION_BLOCK

FUNCTION minimal : INT
VAR_INPUT 
    IN1 : INT;
    IN2 : INT;
END_VAR

IF IN1 <= IN2 THEN
    minimal := IN1;
ELSE
    minimal := IN2;
END_IF;
END_FUNCTION