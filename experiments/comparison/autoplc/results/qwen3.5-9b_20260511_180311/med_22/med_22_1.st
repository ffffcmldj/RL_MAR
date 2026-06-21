FUNCTION_BLOCK CottonCandyMachine
VAR_INPUT
    SugarLevel : REAL;
    SpinningSpeed : INT;
END_VAR
VAR_OUTPUT
    SugarFeeder : BOOL;
    MotorSpeed : INT;
END_VAR

IF SugarLevel < 10.0 THEN
    SugarFeeder := TRUE;
ELSE
    SugarFeeder := FALSE;
END_IF

IF SpinningSpeed > 0 THEN
    MotorSpeed := SpinningSpeed;
ELSE
    MotorSpeed := 0;
END_IF

END_FUNCTION_BLOCK