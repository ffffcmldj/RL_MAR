FUNCTION_BLOCK FB_FactorialCalculator
VAR_INPUT
X : INT;
END_VAR
VAR_OUTPUT
FactorialResult : INT;
FactorialGoodResult : INT;
END_VAR
VAR
TempGoodResult : INT;
END_VAR
TempGoodResult := 0;
IF X >= -3 AND X <= 3 THEN
TempGoodResult := X * X * X * X;
FactorialGoodResult := TempGoodResult;
IF FactorialGoodResult > 1 THEN
FactorialResult := FactorialGoodResult * (FactorialGoodResult - 1);
ELSE
FactorialResult := FactorialGoodResult;
END_IF
ELSE
FactorialGoodResult := 0;
FactorialResult := 1;
END_IF
END_FUNCTION_BLOCK