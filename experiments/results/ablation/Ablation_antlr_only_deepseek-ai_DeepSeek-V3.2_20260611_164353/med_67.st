(*
    FUNCTION_BLOCK: FB_FactorialCalculator
    DESCRIPTION: Calculates factorial-like values with overflow protection.
    INPUTS:
        X : INT - Input value for calculation.
    OUTPUTS:
        FactorialResult : INT - Final calculated result.
        FactorialGoodResult : INT - Intermediate X⁴ result.
    BEHAVIOR:
        - If X is within the range -3 to 3 (inclusive):
            * FactorialGoodResult = X⁴ (X * X * X * X)
            * If FactorialGoodResult > 1:
                FactorialResult = FactorialGoodResult * (FactorialGoodResult - 1)
              Else:
                FactorialResult = FactorialGoodResult
        - If X is outside the range -3 to 3:
            * FactorialResult = 1
            * FactorialGoodResult = 0
        This prevents overflow, as the maximum intermediate value (81) and final value (6480) are within INT range (-32768 to 32767).
*)

FUNCTION_BLOCK FB_FactorialCalculator
VAR_INPUT
    X : INT;
END_VAR

VAR_OUTPUT
    FactorialResult : INT;
    FactorialGoodResult : INT;
END_VAR

VAR
    // No internal variables required for this logic.
END_VAR

BEGIN
    // Initialize outputs to safe default values (invalid input case).
    FactorialResult := 1;
    FactorialGoodResult := 0;

    // Check if input is within the valid processing range.
    IF (X >= -3) AND (X <= 3) THEN
        // Calculate X⁴. Range is safe: max(3⁴, (-3)⁴) = 81.
        FactorialGoodResult := X * X * X * X;

        // Calculate the final result based on the intermediate value.
        IF FactorialGoodResult > 1 THEN
            FactorialResult := FactorialGoodResult * (FactorialGoodResult - 1);
        ELSE
            FactorialResult := FactorialGoodResult;
        END_IF;
    END_IF;
END_FUNCTION_BLOCK;