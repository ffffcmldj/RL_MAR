FUNCTION_BLOCK FB_FactorialCalculator
    VAR_INPUT
        X : INT;
    END_VAR

    VAR_OUTPUT
        FactorialResult : INT;
        FactorialGoodResult : INT;
    END_VAR

    VAR
        TempResult : INT;
    END_VAR

    // Begin processing
    IF (X < -3) OR (X > 3) THEN
        // If X is outside the range of -3 to 3, prevent overflow
        FactorialResult := 1;
        FactorialGoodResult := 0; // Not calculated
    ELSE
        // Calculate FactorialGoodResult as X^4
        TempResult := X * X; // X^2
        TempResult := TempResult * TempResult; // (X^2)^2 = X^4
        FactorialGoodResult := TempResult;

        // Calculate FactorialResult based on FactorialGoodResult
        IF FactorialGoodResult > 1 THEN
            FactorialResult := FactorialGoodResult * (FactorialGoodResult - 1);
        ELSE
            FactorialResult := FactorialGoodResult;
        END_IF
    END_IF
END_FUNCTION_BLOCK