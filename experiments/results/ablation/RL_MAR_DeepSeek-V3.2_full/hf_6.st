FUNCTION_BLOCK RandomNumberGenerator
    VAR_INPUT
        minValue : DINT;
        maxValue : DINT;
        randomSeed_in : DINT;
    END_VAR

    VAR_OUTPUT
        error : BOOL;
        status : WORD;
        randomNumber : DINT;
    END_VAR

    VAR
        seed : DINT;
        range : DINT;
        offset : DINT;
    END_VAR

    IF minValue > maxValue THEN
        error := TRUE;
        status := 16#8200;
        randomNumber := 0;
        RETURN;
    END_IF;

    seed := randomSeed_in;
    IF seed < 0 THEN
        seed := seed * -1;
    END_IF;
    IF seed = 0 THEN
        seed := 1;
    END_IF;

    range := maxValue - minValue + 1;
    offset := seed MOD range;
    randomNumber := minValue + offset;

    error := FALSE;
    status := 16#0000;
END_FUNCTION_BLOCK;