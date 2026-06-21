FUNCTION_BLOCK FB_ValueOut
VAR_INPUT
    valueIn : INT;
    conf : UINT;
END_VAR

VAR_OUTPUT
    ValueOut : INT;
END_VAR

VAR
END_VAR

METHOD ProcessValue : INT
VAR_INPUT
    valueIn : INT;
    conf : UINT;
END_VAR
VAR_OUTPUT
    result : INT;
END_VAR
BEGIN
    result := 0;
    
    CASE conf OF
        1, 2:
            IF valueIn <> 0 THEN
                result := valueIn / 10;
            END_IF;
            
        3:
            CASE valueIn OF
                0:   result := 0;
                300: result := 163;
                600: result := 331;
            ELSE
                result := 0;
            END_CASE;
            
        6, 7:
            IF valueIn = 100 THEN
                result := 319;
            ELSE
                result := 0;
            END_IF;
            
    ELSE
        result := 0;
    END_CASE;
    
    // Ensure non-negative output
    IF result < 0 THEN
        result := 0;
    END_IF;
    
    RETURN result;
END_METHOD

BEGIN
    ValueOut := ProcessValue(valueIn := valueIn, conf := conf);
END_FUNCTION_BLOCK