START_ST
FUNCTION_BLOCK CottonCandyMachine
VAR_INPUT
    SugarLevel : REAL;
    SpinningSpeed : INT;
END_VAR
VAR_OUTPUT
    SugarFeeder : BOOL;
    MotorSpeed : INT;
END_VAR

(* State 0: OPERATE - Continuous evaluation of inputs to set outputs *)
SugarFeeder := (SugarLevel < 10.0);
IF SpinningSpeed > 0 THEN
    MotorSpeed := SpinningSpeed;
ELSE
    MotorSpeed := 0;
END_IF;

END_FUNCTION_BLOCK
END_ST