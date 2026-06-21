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
    tempMinValue: INT;
    tempDigit: INT;
END_VAR

METHOD AnalyzeDigits: BOOL
VAR_INPUT
END_VAR
VAR
END_VAR

    // Input validation
    IF (InputNumber < 0) OR (InputNumber > 9999) THEN
        // Error condition
        error := TRUE;
        status := 16#8001;
        
        // Reset all outputs
        Thousands := 0;
        Hundreds := 0;
        Tens := 0;
        Ones := 0;
        MinDigit := 0;
        
        RETURN FALSE;
    ELSE
        // Valid input
        error := FALSE;
        status := 16#0000;
        
        // Digit separation
        Thousands := InputNumber / 1000;
        Hundreds := (InputNumber MOD 1000) / 100;
        Tens := (InputNumber MOD 100) / 10;
        Ones := InputNumber MOD 10;
        
        // Minimum non-zero digit detection
        tempMinValue := 32767; // Maximum INT value
        
        // Check thousands digit
        IF Thousands > 0 THEN
            IF Thousands < tempMinValue THEN
                tempMinValue := Thousands;
            END_IF;
        END_IF;
        
        // Check hundreds digit
        IF Hundreds > 0 THEN
            IF Hundreds < tempMinValue THEN
                tempMinValue := Hundreds;
            END_IF;
        END_IF;
        
        // Check tens digit
        IF Tens > 0 THEN
            IF Tens < tempMinValue THEN
                tempMinValue := Tens;
            END_IF;
        END_IF;
        
        // Check ones digit
        IF Ones > 0 THEN
            IF Ones < tempMinValue THEN
                tempMinValue := Ones;
            END_IF;
        END_IF;
        
        // Set MinDigit output
        IF tempMinValue = 32767 THEN
            // All digits are zero
            MinDigit := 0;
        ELSE
            MinDigit := tempMinValue;
        END_IF;
        
        RETURN TRUE;
    END_IF;
END_METHOD

// Main execution
AnalyzeDigits();

END_FUNCTION_BLOCK