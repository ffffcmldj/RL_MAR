ructured-text
START_ST
FUNCTION_BLOCK GenerateRandomNumber
VAR_INPUT
    minValue: DINT; // The minimum value of the random number range
    maxValue: DINT; // The maximum value of the random number range
    randomSeed_in: DINT; // An external DINT value used as the seed for randomness
END_VAR

VAR_OUTPUT
    error: BOOL; // FALSE if no error occurred; TRUE if an error occurred during execution
    status: WORD; // Status code (16#0000: No error, 16#8200: Range incorrect)
    randomNumber: DINT; // The generated random number
END_VAR

VAR
    seed: DINT; // TEMPORARY VARIABLE TO HOLD THE SEED VALUE
END_VAR

// INITIALIZE
error := FALSE;
status := 16#0000;
randomNumber := 0;

// CHECK_RANGE
IF minValue > maxValue THEN
    // SET_ERROR
    error := TRUE;
    status := 16#8200;
ELSE
    // GENERATE_RANDOM_NUMBER
    seed := randomSeed_in;
    IF seed < 0 THEN
        seed := -seed; // Ensure the seed is positive
    END_IF;
    randomNumber := (seed MOD (maxValue - minValue + 1)) + minValue;
END_IF;

END_FUNCTION_BLOCK
END_ST