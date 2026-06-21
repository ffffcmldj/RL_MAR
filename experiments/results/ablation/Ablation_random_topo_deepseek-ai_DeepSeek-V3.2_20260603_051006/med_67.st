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

IF (X >= -3) AND (X <= 3) THEN
    tempGoodResult := X * X * X * X;
    FactorialGoodResult := tempGoodResult;
    
    IF tempGoodResult > 1 THEN
        FactorialResult := tempGoodResult * (tempGoodResult - 1);
    ELSE
        FactorialResult := tempGoodResult;
    END_IF;
ELSE
    FactorialGoodResult := 0;
    FactorialResult := 1;
END_IF;

END_FUNCTION_BLOCK