FUNCTION_BLOCK FB_FactorialCalculator
VAR_INPUT
    X : INT;
END_VAR

VAR_OUTPUT
    FactorialResult : INT;
    FactorialGoodResult : INT;
END_VAR

VAR
    tempResult : INT;
    i : INT;
END_VAR

// Initialize outputs
FactorialResult := 0;
FactorialGoodResult := 0;

// Check if X is within valid range (-3 to 3)
IF (X >= -3) AND (X <= 3) THEN
    // Calculate FactorialGoodResult = X * X * X * X
    tempResult := X;
    
    // Multiply X by itself 3 more times (total 4 multiplications)
    FOR i := 1 TO 3 DO
        tempResult := tempResult * X;
    END_FOR;
    
    FactorialGoodResult := tempResult;
    
    // Calculate FactorialResult based on FactorialGoodResult
    IF FactorialGoodResult > 1 THEN
        FactorialResult := FactorialGoodResult * (FactorialGoodResult - 1);
    ELSE
        FactorialResult := FactorialGoodResult;
    END_IF;
ELSE
    // X is outside valid range, prevent overflow
    FactorialResult := 1;
    FactorialGoodResult := 0;
END_IF;

END_FUNCTION_BLOCK