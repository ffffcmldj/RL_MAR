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
    tempResult : INT;
END_VAR

// Main logic
IF (X >= -3) AND (X <= 3) THEN
    // Calculate FactorialGoodResult = X * X * X * X
    tempGoodResult := X * X;
    tempGoodResult := tempGoodResult * X;
    tempGoodResult := tempGoodResult * X;
    FactorialGoodResult := tempGoodResult;
    
    // Calculate FactorialResult
    IF FactorialGoodResult > 1 THEN
        tempResult := FactorialGoodResult - 1;
        FactorialResult := FactorialGoodResult * tempResult;
    ELSE
        FactorialResult := FactorialGoodResult;
    END_IF;
ELSE
    // X is outside range [-3, 3]
    FactorialGoodResult := 0;
    FactorialResult := 1;
END_IF;
END_FUNCTION_BLOCK