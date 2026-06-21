scl
START_ST
FUNCTION_BLOCK RandomNumberGenerator
VAR_INPUT
    minValue : DINT; // Minimum value of the random number range
    maxValue : DINT; // Maximum value of the random number range
    randomSeed_in : DINT; // External seed value for randomness
END_VAR
VAR_OUTPUT
    error : BOOL; // Error flag
    status : WORD; // Status code
    randomNumber : DINT; // Generated random number
END_VAR
VAR
    adjustedSeed : DINT; // Positive version of the input seed
    range : DINT; // Calculated range of random numbers
END_VAR

// Step 1: Validate the range
IF minValue > maxValue THEN
    error := TRUE; // Set error flag
    status := 16#8200; // Set status to range incorrect
    RETURN; // Exit the function block
END_IF

// Step 2: Adjust the seed to ensure it is positive
IF randomSeed_in < 0 THEN
    adjustedSeed := ABS(randomSeed_in); // Convert to positive
ELSE
    adjustedSeed := randomSeed_in; // Use the seed as is
END_IF

// Step 3: Calculate the range of random numbers
range := maxValue - minValue + 1;

// Step 4: Generate the random number
randomNumber := (adjustedSeed MOD range) + minValue;

// Step 5: Set the output status
error := FALSE; // No error occurred
status := 16#0000; // Set status to no error

END_FUNCTION_BLOCK
END_ST