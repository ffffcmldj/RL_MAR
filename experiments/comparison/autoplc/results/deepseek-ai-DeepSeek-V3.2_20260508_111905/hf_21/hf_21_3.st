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

FUNCTION_BLOCK FB_SplitNumber
VAR_INPUT 
    InputNumber : INT; 
END_VAR

VAR_OUTPUT 
    Thousands : INT;
    Hundreds : INT;
    Tens : INT;
    Ones : INT;
    MinDigit : INT;  (* Renamed from Min to avoid reserved keyword conflict *)
    error : BOOL; 
    status : WORD; 
END_VAR

VAR 
    tempNumber : INT; 
    minValue : INT;
    digit : INT;
    i : INT;
END_VAR

    // 1. Input Validation
    IF (InputNumber < 0) OR (InputNumber > 9999) THEN
        // Invalid input case
        error := TRUE;
        status := 16#8001;
        Thousands := 0;
        Hundreds := 0;
        Tens := 0;
        Ones := 0;
        MinDigit := 0;  (* Updated to match renamed variable *)
    ELSE
        // Valid input case
        error := FALSE;
        status := 16#0000;
        
        // 2. Digit Separation Logic
        Thousands := InputNumber / 1000;
        tempNumber := InputNumber MOD 1000;
        Hundreds := tempNumber / 100;
        tempNumber := tempNumber MOD 100;
        Tens := tempNumber / 10;
        Ones := tempNumber MOD 10;
        
        // 3. Minimum Value Detection
        minValue := 32767; // Initialize to maximum INT value
        
        // Check Thousands digit
        IF Thousands > 0 THEN
            minValue := minimal(Thousands, minValue);
        END_IF;
        
        // Check Hundreds digit
        IF Hundreds > 0 THEN
            minValue := minimal(Hundreds, minValue);
        END_IF;
        
        // Check Tens digit
        IF Tens > 0 THEN
            minValue := minimal(Tens, minValue);
        END_IF;
        
        // Check Ones digit
        IF Ones > 0 THEN
            minValue := minimal(Ones, minValue);
        END_IF;
        
        // Set MinDigit output
        IF minValue = 32767 THEN
            // All digits were zero
            MinDigit := 0;
        ELSE
            MinDigit := minValue;
        END_IF;
    END_IF;
END_FUNCTION_BLOCK