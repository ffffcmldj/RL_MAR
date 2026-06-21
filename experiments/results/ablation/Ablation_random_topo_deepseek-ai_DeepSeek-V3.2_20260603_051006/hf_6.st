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
    internalSeed : DINT;
END_VAR

// Initialize internal seed with provided seed
internalSeed := randomSeed_in;

// Ensure seed is positive
IF internalSeed < 0 THEN
    internalSeed := -internalSeed;
END_IF;

// Handle zero seed case
IF internalSeed = 0 THEN
    internalSeed := 1;
END_IF;

// Check for invalid range
IF minValue > maxValue THEN
    error := TRUE;
    status := 16#8200;
    randomNumber := 0;
ELSE
    // Generate random number using modulo arithmetic
    internalSeed := (internalSeed * 1103515245 + 12345) MOD 2147483647;
    randomNumber := minValue + (internalSeed MOD (maxValue - minValue + 1));
    
    error := FALSE;
    status := 16#0000;
END_IF;
END_FUNCTION_BLOCK