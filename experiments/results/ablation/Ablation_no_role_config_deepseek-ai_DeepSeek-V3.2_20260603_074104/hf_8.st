FUNCTION_BLOCK FB_HexDigitAnalyzer
VAR_INPUT
    InputNumber: INT;
END_VAR

VAR_OUTPUT
    Thousands: INT;
    Hundreds: INT;
    Tens: INT;
    Ones: INT;
    MinDigit: INT;
    error: BOOL;
    status: WORD;
END_VAR

VAR
    tempMin: INT;
    digit: INT;
END_VAR

METHOD ProcessDigits: BOOL
VAR_INPUT
END_VAR
VAR
    localMin: INT;
END_VAR

    // Initialize local minimum to maximum possible value
    localMin := 32767;
    
    // Check thousands digit
    digit := Thousands;
    IF digit <> 0 THEN
        IF digit < localMin THEN
            localMin := digit;
        END_IF;
    END_IF;
    
    // Check hundreds digit
    digit := Hundreds;
    IF digit <> 0 THEN
        IF digit < localMin THEN
            localMin := digit;
        END_IF;
    END_IF;
    
    // Check tens digit
    digit := Tens;
    IF digit <> 0 THEN
        IF digit < localMin THEN
            localMin := digit;
        END_IF;
    END_IF;
    
    // Check ones digit
    digit := Ones;
    IF digit <> 0 THEN
        IF digit < localMin THEN
            localMin := digit;
        END_IF;
    END_IF;
    
    // Set MinDigit
    IF localMin = 32767 THEN
        MinDigit := 0;  // All digits were zero
    ELSE
        MinDigit := localMin;
    END_IF;
    
    RETURN TRUE;
END_METHOD

// Main execution
IF (InputNumber < 0) OR (InputNumber > 9999) THEN
    // Error condition
    error := TRUE;
    status := 16#8001;
    Thousands := 0;
    Hundreds := 0;
    Tens := 0;
    Ones := 0;
    MinDigit := 0;
ELSE
    // Valid input - process normally
    error := FALSE;
    status := 16#0000;
    
    // Separate digits
    Thousands := InputNumber / 1000;
    Hundreds := (InputNumber MOD 1000) / 100;
    Tens := (InputNumber MOD 100) / 10;
    Ones := InputNumber MOD 10;
    
    // Find minimum non-zero digit
    ProcessDigits();
END_IF;