FUNCTION_BLOCK FB_HexDigitAnalyzer
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
    tempValue : INT;
    minValue : INT;
    i : INT;
    digit : INT;
END_VAR

    IF InputNumber < 0 OR InputNumber > 9999 THEN
        error := TRUE;
        status := 16#8001;
        Thousands := 0;
        Hundreds := 0;
        Tens := 0;
        Ones := 0;
        Min := 0;
    ELSE
        error := FALSE;
        status := 16#0000;
        
        Thousands := InputNumber / 1000;
        tempValue := InputNumber MOD 1000;
        Hundreds := tempValue / 100;
        tempValue := InputNumber MOD 100;
        Tens := tempValue / 10;
        Ones := InputNumber MOD 10;
        
        minValue := 32767;
        
        FOR i := 0 TO 3 DO
            CASE i OF
                0: digit := Thousands;
                1: digit := Hundreds;
                2: digit := Tens;
                3: digit := Ones;
            END_CASE
            
            IF digit > 0 THEN
                minValue := MIN(minValue, digit);
            END_IF;
        END_FOR
        
        IF minValue = 32767 THEN
            Min := 0;
        ELSE
            Min := minValue;
        END_IF;
    END_IF;
END_FUNCTION_BLOCK