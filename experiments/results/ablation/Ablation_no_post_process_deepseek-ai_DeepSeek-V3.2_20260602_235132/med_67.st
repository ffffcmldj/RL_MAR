TYPE
    E_CalculationStatus : (eStatus_InvalidInput, eStatus_ValidInput, eStatus_OverflowPrevented);
END_TYPE

FUNCTION_BLOCK FB_FactorialCalculator
VAR_INPUT
    X : INT;
END_VAR

VAR_OUTPUT
    FactorialResult : INT;
    FactorialGoodResult : INT;
    eStatus : E_CalculationStatus;
END_VAR

VAR
    nTempGoodResult : INT;
END_VAR

(* Initialize outputs *)
FactorialGoodResult := 0;
FactorialResult := 1;
eStatus := eStatus_InvalidInput;

(* Check input range *)
IF (X >= -3) AND (X <= 3) THEN
    (* Calculate FactorialGoodResult as X⁴ *)
    nTempGoodResult := X * X * X * X;
    FactorialGoodResult := nTempGoodResult;
    
    (* Calculate FactorialResult based on FactorialGoodResult *)
    IF nTempGoodResult > 1 THEN
        FactorialResult := nTempGoodResult * (nTempGoodResult - 1);
    ELSE
        FactorialResult := nTempGoodResult;
    END_IF;
    
    eStatus := eStatus_ValidInput;
ELSE
    (* Handle out-of-range input to prevent overflow *)
    FactorialGoodResult := 0;
    FactorialResult := 1;
    eStatus := eStatus_OverflowPrevented;
END_IF;

END_FUNCTION_BLOCK;