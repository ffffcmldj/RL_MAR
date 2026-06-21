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
END_VAR

// Check if range is valid
IF minValue > maxValue THEN
    error := TRUE;
    status := 16#8200;
    randomNumber := 0;
ELSE
    // Ensure seed is positive using absolute value
    seed := ABS(randomSeed_in);
    
    // Generate random number within range using modulo arithmetic
    // Use DINT casting to avoid LINT conversion issues
    randomNumber := minValue + DINT_TO_DINT(seed MOD (maxValue - minValue + 1));
    
    error := FALSE;
    status := 16#0000;
END_IF