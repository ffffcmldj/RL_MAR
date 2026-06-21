START_ST
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

// STATE 0: INITIALIZE (Input Validation)
// Logic: Initialize temporary variables.
// If X is outside the range [-3, 3], set outputs to safe default values to prevent overflow logic.
IF (X < -3) OR (X > 3) THEN
    tempGoodResult := 0;
    FactorialGoodResult := 0;
    FactorialResult := 1;
ELSIF (X >= -3) AND (X <= 3) THEN
    // STATE 1: CALCULATE GOOD RESULT (X^4)
    // Logic: Calculate X * X * X * X
    tempGoodResult := X * X * X * X;
    FactorialGoodResult := tempGoodResult;

    // STATE 2: CALCULATE FINAL RESULT (Conditional Logic)
    // Logic: If FactorialGoodResult > 1, compute FactorialGoodResult * (FactorialGoodResult - 1)
    // Otherwise, keep FactorialGoodResult as is.
    IF FactorialGoodResult > 1 THEN
        FactorialResult := FactorialGoodResult * (FactorialGoodResult - 1);
    ELSE
        FactorialResult := FactorialGoodResult;
    END_IF;
END_IF;

END_FUNCTION_BLOCK
END_ST