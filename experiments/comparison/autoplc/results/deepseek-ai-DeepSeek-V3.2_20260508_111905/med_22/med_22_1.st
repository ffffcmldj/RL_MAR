FUNCTION_BLOCK CottonCandyMachine
VAR_INPUT
    SugarLevel : REAL; (* Input for sugar level *)
    SpinningSpeed : INT; (* Input for spinning speed *)
END_VAR
VAR_OUTPUT
    SugarFeeder : BOOL; (* Output to control sugar feeding *)
    MotorSpeed : INT; (* Output to control spinning motor speed *)
END_VAR

(* Sugar feeding control logic *)
IF SugarLevel < 10.0 THEN
    SugarFeeder := TRUE;
ELSE
    SugarFeeder := FALSE;
END_IF;

(* Motor speed control logic *)
IF SpinningSpeed > 0 THEN
    MotorSpeed := SpinningSpeed;
ELSE
    MotorSpeed := 0;
END_IF;

END_FUNCTION_BLOCK