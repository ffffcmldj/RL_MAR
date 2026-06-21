FUNCTION_BLOCK FB_ValueOut
VAR_INPUT
    valueIn : INT;
    conf : UINT;
END_VAR
VAR
    tempResult : INT;
END_VAR
VAR_OUTPUT
    ValueOut : INT;
END_VAR

    tempResult := 0;

    CASE conf OF
        1, 2:
            tempResult := valueIn / 10;
            IF tempResult < 0 THEN
                tempResult := -tempResult;
            END_IF;
        3:
            IF valueIn = 0 THEN
                tempResult := 0;
            ELSIF valueIn = 300 THEN
                tempResult := 163;
            ELSIF valueIn = 600 THEN
                tempResult := 331;
            ELSE
                tempResult := 0;
            END_IF;
        6, 7:
            IF valueIn = 100 THEN
                tempResult := 319;
            ELSE
                tempResult := 0;
            END_IF;
        ELSE
            tempResult := 0;
        END_CASE;

    ValueOut := tempResult;

END_FUNCTION_BLOCK