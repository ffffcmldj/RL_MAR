FUNCTION_BLOCK FB_FactorialCalculator
VAR_INPUT
    X : INT;
END_VAR

VAR_OUTPUT
    FactorialResult : INT;
    FactorialGoodResult : INT;
END_VAR

VAR
    tempGoodResult : INT;
END_VAR

// Initialize outputs
FactorialGoodResult := 0;
FactorialResult := 1;

// Check if input is within valid range
IF (X >= -3) AND (X <= 3) THEN
    // Calculate X^4 (X multiplied by itself 4 times)
    tempGoodResult := X * X * X * X;
    FactorialGoodResult := tempGoodResult;
    
    // Calculate FactorialResult based on FactorialGoodResult
    IF tempGoodResult > 1 THEN
        FactorialResult := tempGoodResult * (tempGoodResult - 1);
    ELSE
        FactorialResult := tempGoodResult;
    END_IF;
END_IF;

// If X is outside range [-3, 3], outputs remain at initialized values
// FactorialResult = 1 (as per overflow prevention requirement)
// FactorialGoodResult = 0
END_FUNCTION_BLOCK