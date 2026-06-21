FUNCTION_BLOCK FB_SplitNumber
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
    tempNumber : INT;
    minValue : INT;
    i : INT;
    digit : INT;
END_VAR

    Thousands := 0;
    Hundreds := 0;
    Tens := 0;
    Ones := 0;
    Min := 0;
    error := FALSE;
    status := 16#0000;

    tempNumber := InputNumber;
    minValue := 32767;

    IF InputNumber < 0 OR InputNumber > 9999 THEN
        error := TRUE;
        status := 16#8001;
    ELSE
        Thousands := InputNumber / 1000;
        Hundreds := (InputNumber MOD 1000) / 100;
        Tens := (InputNumber MOD 100) / 10;
        Ones := InputNumber MOD 10;

        FOR i := 1 TO 4 DO
            CASE i OF
                1: digit := Thousands;
                2: digit := Hundreds;
                3: digit := Tens;
                4: digit := Ones;
            END_CASE;

            IF digit > 0 THEN
                minValue := MIN(digit, minValue);
            END_IF;
        END_FOR;

        IF minValue = 32767 THEN
            Min := 0;
        ELSE
            Min := minValue;
        END_IF;
    END_IF;
END_FUNCTION_BLOCK