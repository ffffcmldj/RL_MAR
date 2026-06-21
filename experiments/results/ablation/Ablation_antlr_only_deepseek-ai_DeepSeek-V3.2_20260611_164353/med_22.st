FUNCTION_BLOCK CottonCandyMachine
VAR_INPUT
    SugarLevel : REAL; (* Input for sugar level *)
    SpinningSpeed : INT; (* Input for spinning speed *)
END_VAR
VAR_OUTPUT
    SugarFeeder : BOOL; (* Output to control sugar feeding *)
    MotorSpeed : INT; (* Output to control spinning motor speed *)
END_VAR

(* No internal variables required for this simple combinational logic *)

(* Sugar feeding control: Activate when sugar level is below 10.0 units *)
SugarFeeder := SugarLevel < 10.0;

(* Motor speed control: Set to input speed if positive, otherwise 0 *)
IF SpinningSpeed > 0 THEN
    MotorSpeed := SpinningSpeed;
ELSE
    MotorSpeed := 0;
END_IF;

END_FUNCTION_BLOCK