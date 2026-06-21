START_ST
FUNCTION_BLOCK CottonCandyMachine
VAR_INPUT
    SugarLevel : REAL; (* Input for sugar level *)
    SpinningSpeed : INT; (* Input for spinning speed *)
END_VAR
VAR_OUTPUT
    SugarFeeder : BOOL; (* Output to control sugar feeding *)
    MotorSpeed : INT; (* Output to control spinning motor speed *)
END_VAR
VAR
    CurrentFeederState : INT; (* Tracks the current state of the sugar logic: 0=Low, 1=High *)
    CurrentMotorState : INT; (* Tracks the current state of the motor logic: 0=Stop, 1=Run *)
END_VAR

(* STATE 0: FEEDER_STATE_LOW (Condition: SugarLevel < 10.0) *)
(* STATE 1: FEEDER_STATE_HIGH (Condition: SugarLevel >= 10.0) *)
(* STATE 2: MOTOR_STATE_RUN (Condition: SpinningSpeed > 0) *)
(* STATE 3: MOTOR_STATE_STOP (Condition: SpinningSpeed <= 0) *)

(* Evaluate Sugar Level to determine Feeder State *)
IF SugarLevel < 10.0 THEN
    CurrentFeederState := 0; (* Low Sugar Detected *)
ELSE
    CurrentFeederState := 1; (* High Sugar Detected *)
END_IF;

(* Evaluate Spinning Speed to determine Motor State *)
IF SpinningSpeed > 0 THEN
    CurrentMotorState := 1; (* Positive Speed Requested *)
ELSE
    CurrentMotorState := 0; (* Zero/Negative Speed Requested *)
END_IF;

(* Assign Outputs based on Current States *)
(* STATE 0 (Low Sugar): SugarFeeder = TRUE *)
(* STATE 1 (High Sugar): SugarFeeder = FALSE *)
IF CurrentFeederState = 0 THEN
    SugarFeeder := TRUE;
ELSE
    SugarFeeder := FALSE;
END_IF;

(* STATE 1 (Motor Run): MotorSpeed = SpinningSpeed *)
(* STATE 0 (Motor Stop): MotorSpeed = 0 *)
IF CurrentMotorState = 1 THEN
    MotorSpeed := SpinningSpeed;
ELSE
    MotorSpeed := 0;
END_IF;

END_FUNCTION_BLOCK
END_ST