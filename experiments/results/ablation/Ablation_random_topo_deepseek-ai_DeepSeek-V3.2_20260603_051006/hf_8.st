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

METHOD FindMin: INT
VAR_INPUT
    a: INT;
    b: INT;
END_VAR
    IF a < b THEN
        FindMin := a;
    ELSE
        FindMin := b;
    END_IF;
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
    
    // Digit separation
    Thousands := InputNumber / 1000;
    Hundreds := (InputNumber MOD 1000) / 100;
    Tens := (InputNumber MOD 100) / 10;
    Ones := InputNumber MOD 10;
    
    // Minimum non-zero digit detection
    tempMinValue := 32767; // Maximum INT value
    
    // Check thousands digit
    IF Thousands > 0 THEN
        tempMinValue := FindMin(tempMinValue, Thousands);
    END_IF;
    
    // Check hundreds digit
    IF Hundreds > 0 THEN
        tempMinValue := FindMin(tempMinValue, Hundreds);
    END_IF;
    
    // Check tens digit
    IF Tens > 0 THEN
        tempMinValue := FindMin(tempMinValue, Tens);
    END_IF;
    
    // Check ones digit
    IF Ones > 0 THEN
        tempMinValue := FindMin(tempMinValue, Ones);
    END_IF;
    
    // Set MinDigit result
    IF tempMinValue = 32767 THEN
        // All digits were zero
        MinDigit := 0;
    ELSE
        MinDigit := tempMinValue;
    END_IF;
END_IF;
END_FUNCTION_BLOCK