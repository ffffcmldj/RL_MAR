FUNCTION_BLOCK hf_6
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
    internalSeed : DWORD := 0;
    firstCall : BOOL := TRUE;
    a : DWORD := 1103515245;
    c : DWORD := 12345;
    m : DWORD := 2147483648;  // 2^31
    preparedSeed : DWORD;
    range : DINT;
    tempSeed : DWORD;
END_VAR

// Input validation
IF minValue > maxValue THEN
    error := TRUE;
    status := 16#8200;
    randomNumber := 0;
    RETURN;
END_IF;

// Seed preparation
IF firstCall THEN
    // Ensure seed is non-negative by taking absolute value
    IF randomSeed_in < 0 THEN
        preparedSeed := DWORD_TO_DINT(ABS(randomSeed_in));
    ELSE
        preparedSeed := DINT_TO_DWORD(randomSeed_in);
    END_IF;
    
    // Initialize internal seed
    internalSeed := preparedSeed;
    firstCall := FALSE;
END_IF;

// Update internal seed using linear congruential method
tempSeed := internalSeed;
internalSeed := (tempSeed * a + c) MOD m;

// Calculate range size
range := maxValue - minValue + 1;

// Generate random number within specified range
randomNumber := minValue + DWORD_TO_DINT(internalSeed MOD DINT_TO_DWORD(range));

// Set success outputs
error := FALSE;
status := 16#0000;
END_FUNCTION_BLOCK