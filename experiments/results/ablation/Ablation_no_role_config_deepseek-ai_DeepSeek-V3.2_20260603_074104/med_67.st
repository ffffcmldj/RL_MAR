FUNCTION_BLOCK FB_FactorialCalculator
VAR_INPUT
    X : INT;
END_VAR

VAR_OUTPUT
    FactorialResult : INT;
    FactorialGoodResult : INT;
END_VAR

VAR
END_VAR

// Initialize outputs
FactorialGoodResult := 0;
FactorialResult := 0;

// Check if input is within safe range
IF (X >= -3) AND (X <= 3) THEN
    // Calculate X^4 (X multiplied by itself 4 times)
    FactorialGoodResult := X * X * X * X;
    
    // Calculate FactorialResult based on FactorialGoodResult
    IF FactorialGoodResult > 1 THEN
        FactorialResult := FactorialGoodResult * (FactorialGoodResult - 1);
    ELSE
        FactorialResult := FactorialGoodResult;
    END_IF;
ELSE
    // Overflow prevention for inputs outside range
    FactorialResult := 1;
    FactorialGoodResult := 0;
END_IF;

END_FUNCTION_BLOCK