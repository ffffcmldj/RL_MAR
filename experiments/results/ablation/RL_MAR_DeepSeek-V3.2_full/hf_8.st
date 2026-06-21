FUNCTION_BLOCK FB_HexDigitAnalyzer
VAR_INPUT
    InputNumber : INT;
END_VAR

VAR_OUTPUT
    Thousands : INT;
    Hundreds : INT;
    Tens : INT;
    Ones : INT;
    MinDigit : INT;
    error : BOOL;
    status : WORD;
END_VAR

VAR
    tempMin : INT;
    digit : INT;
END_VAR

METHOD ProcessDigits : BOOL
VAR_INPUT
END_VAR
VAR
END_VAR

    // Input validation
    IF (InputNumber < 0) OR (InputNumber > 9999) THEN
        error := TRUE;
        status := 16#8001;
        Thousands := 0;
        Hundreds := 0;
        Tens := 0;
        Ones := 0;
        MinDigit := 0;
        RETURN FALSE;
    ELSE
        error := FALSE;
        status := 16#0000;
    END_IF;

    // Digit separation
    Thousands := InputNumber / 1000;
    Hundreds := (InputNumber MOD 1000) / 100;
    Tens := (InputNumber MOD 100) / 10;
    Ones := InputNumber MOD 10;

    // Minimum non-zero digit detection
    tempMin := 32767; // Maximum INT value
    
    // Check Thousands
    digit := Thousands;
    IF digit > 0 THEN
        IF digit < tempMin THEN
            tempMin := digit;
        END_IF;
    END_IF;
    
    // Check Hundreds
    digit := Hundreds;
    IF digit > 0 THEN
        IF digit < tempMin THEN
            tempMin := digit;
        END_IF;
    END_IF;
    
    // Check Tens
    digit := Tens;
    IF digit > 0 THEN
        IF digit < tempMin THEN
            tempMin := digit;
        END_IF;
    END_IF;
    
    // Check Ones
    digit := Ones;
    IF digit > 0 THEN
        IF digit < tempMin THEN
            tempMin := digit;
        END_IF;
    END_IF;
    
    // Set MinDigit
    IF tempMin = 32767 THEN
        MinDigit := 0; // All digits were zero
    ELSE
        MinDigit := tempMin;
    END_IF;
    
    RETURN TRUE;
END_METHOD

// Main execution
ProcessDigits();