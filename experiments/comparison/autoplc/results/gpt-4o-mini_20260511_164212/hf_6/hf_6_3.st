FUNCTION_BLOCK hf_6
VAR_INPUT:
    minValue : DINT; // The minimum value of the random number range
    maxValue : DINT; // The maximum value of the random number range
    randomSeed_in : DINT; // An external DINT value used as the seed for randomness
END_VAR_INPUT

VAR_OUTPUT:
    error : BOOL; // FALSE if no error occurred; TRUE if an error occurred during the execution
    status : WORD; // Status code (16#0000: No error, 16#8200: Range incorrect)
    randomNumber : DINT; // The generated random number
END_VAR_OUTPUT

VAR:
    rangeSize : DINT; // Size of the range for random number generation
    randomValue : DINT; // Temporary variable to hold the generated random value
END_VAR

// Initialization
error := FALSE;
status := 16#0000;

// Input Validation
IF minValue > maxValue THEN
    error := TRUE;
    status := 16#8200; // Range incorrect
ELSE
    // Random Number Generation
    IF randomSeed_in < 0 THEN
        randomSeed_in := -randomSeed_in; // Ensure seed is positive
    END_IF;

    rangeSize := maxValue - minValue + 1; // Calculate the range size
    randomValue := randomSeed_in MOD rangeSize; // Generate random value using modulo
    randomNumber := minValue + randomValue; // Adjust to fall within the specified range

    // Output Assignment
    error := FALSE;
    status := 16#0000; // No error
END_IF;

END_FUNCTION_BLOCK