FUNCTION_BLOCK CottonCandyMachine
VAR_INPUT
    SugarLevel : REAL; (* Input for sugar level *)
    SpinningSpeed : INT; (* Input for spinning speed *)
END_VAR
VAR_OUTPUT
    SugarFeeder : BOOL; (* Output to control sugar feeding *)
    MotorSpeed : INT; (* Output to control spinning motor speed *)
END_VAR

(* Initialization of output variables *)
SugarFeeder := FALSE;
MotorSpeed := 0;

(* Control Logic for SugarFeeder *)
IF SugarLevel < 10.0 THEN
    SugarFeeder := TRUE; (* Activate sugar feeding *)
ELSE
    SugarFeeder := FALSE; (* Deactivate sugar feeding *)
END_IF;

(* Control Logic for MotorSpeed *)
IF SpinningSpeed > 0 THEN
    MotorSpeed := SpinningSpeed; (* Set motor speed to input spinning speed *)
ELSE
    MotorSpeed := 0; (* Set motor speed to 0 if input speed is 0 or negative *)
END_IF;

END_FUNCTION_BLOCK