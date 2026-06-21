FUNCTION_BLOCK FB_FactorialCalculator
    VAR_INPUT
        X : INT;
    END_VAR

    VAR_OUTPUT
        FactorialResult : INT;
        FactorialGoodResult : INT;
    END_VAR

    // Initialization
    FactorialResult := 1; // Default value for FactorialResult
    FactorialGoodResult := 0; // Default value for FactorialGoodResult

    // Input Validation
    IF (X >= -3) AND (X <= 3) THEN
        // Compute FactorialGoodResult as X raised to the power of 4
        FactorialGoodResult := X * X * X * X;

        // Compute FactorialResult based on FactorialGoodResult
        IF FactorialGoodResult > 1 THEN
            FactorialResult := FactorialGoodResult * (FactorialGoodResult - 1);
        ELSE
            FactorialResult := FactorialGoodResult;
        END_IF;
    ELSE
        // If X is outside the range, set FactorialResult to 1
        FactorialResult := 1;
        FactorialGoodResult := 0; // Optional: Indicate no valid computation
    END_IF;
END_FUNCTION_BLOCK