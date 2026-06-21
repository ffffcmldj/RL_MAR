PROCEDURE hf_6
VAR
    minValue : DINT;
    maxValue : DINT;
    randomSeed_in : DINT;
    error : BOOL;
    status : WORD;
    randomNumber : DINT;
    rangeSpan : DINT;
    normalizedSeed : DINT;
    tempValue : DINT;
END_VAR

    IF minValue > maxValue THEN
        error := TRUE;
        status := 16#8200;
        randomNumber := 0;
    ELSE
        error := FALSE;
        status := 16#0000;
        
        normalizedSeed := randomSeed_in;
        IF normalizedSeed < 0 THEN
            tempValue := 0;
            WHILE tempValue < ABS(normalizedSeed) DO
                tempValue := tempValue + 1;
            END_WHILE;
            normalizedSeed := tempValue;
        END_IF;
        
        rangeSpan := maxValue - minValue + 1;
        IF rangeSpan <= 0 THEN
            randomNumber := 0;
        ELSE
            tempValue := normalizedSeed MOD rangeSpan;
            randomNumber := minValue + tempValue;
        END_IF;
    END_IF;
END_PROCEDURE