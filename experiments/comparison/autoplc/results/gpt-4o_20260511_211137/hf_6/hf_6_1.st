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
        rangeSpan : DINT;
        positiveSeed : DINT;
    END_VAR

    // Step 1: Input Validation
    IF minValue > maxValue THEN
        error := TRUE;
        status := 16#8200; // Range incorrect
        RETURN;
    END_IF

    // Step 2: Seed Preparation
    IF randomSeed_in < 0 THEN
        positiveSeed := -randomSeed_in; // Convert to positive if negative
    ELSE
        positiveSeed := randomSeed_in;
    END_IF

    // Step 3: Random Number Generation
    rangeSpan := maxValue - minValue + 1; // Calculate the range span
    randomNumber := (positiveSeed MOD rangeSpan) + minValue; // Generate random number within range

    // Step 4: Output Assignment
    error := FALSE;
    status := 16#0000; // No error

END_FUNCTION_BLOCK