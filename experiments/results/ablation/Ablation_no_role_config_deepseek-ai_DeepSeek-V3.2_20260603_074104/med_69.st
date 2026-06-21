FUNCTION_BLOCK FB_ValueOut
VAR_INPUT
    valueIn : INT;
    conf : UINT;
END_VAR
VAR_OUTPUT
    ValueOut : INT;
END_VAR

CASE conf OF
    1,2:
        ValueOut := valueIn / 10;
        
    3:
        IF valueIn = 0 THEN
            ValueOut := 0;
        ELSIF valueIn = 300 THEN
            ValueOut := 163;
        ELSIF valueIn = 600 THEN
            ValueOut := 331;
        ELSE
            ValueOut := 0;
        END_IF;
        
    6,7:
        IF valueIn = 100 THEN
            ValueOut := 319;
        ELSE
            ValueOut := 0;
        END_IF;
        
    ELSE
        ValueOut := 0;
END_CASE;

END_FUNCTION_BLOCK