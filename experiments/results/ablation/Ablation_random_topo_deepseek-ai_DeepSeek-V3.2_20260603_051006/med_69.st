FUNCTION_BLOCK FB_ValueOut
VAR_INPUT
    valueIn : INT;
    conf : UINT;
END_VAR

VAR_OUTPUT
    ValueOut : INT;
END_VAR

VAR
    tempValue : INT;
END_VAR

METHOD ProcessValue : INT
VAR_INPUT
    inValue : INT;
    inConf : UINT;
END_VAR
VAR
    result : INT;
END_VAR

    result := 0;
    
    CASE inConf OF
        1, 2:
            IF inValue <> 0 THEN
                result := inValue / 10;
            ELSE
                result := 0;
            END_IF;
            
        3:
            CASE inValue OF
                0:   result := 0;
                300: result := 163;
                600: result := 331;
            ELSE
                result := 0;
            END_CASE;
            
        6, 7:
            IF inValue = 100 THEN
                result := 319;
            ELSE
                result := 0;
            END_IF;
            
    ELSE
        result := 0;
    END_CASE;
    
    // Ensure non-negative result
    IF result < 0 THEN
        result := 0;
    END_IF;
    
    ProcessValue := result;
END_METHOD

// Main execution
ValueOut := ProcessValue(valueIn := valueIn, inConf := conf);
END_FUNCTION_BLOCK