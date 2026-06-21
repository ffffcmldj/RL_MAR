FUNCTION_BLOCK CottonCandyMachine
VAR_INPUT
    SugarLevel : REAL; (* Current sugar level measurement *)
    SpinningSpeed : INT; (* Desired spinning speed command *)
END_VAR
VAR_OUTPUT
    SugarFeeder : BOOL; (* Control signal for sugar feeding mechanism *)
    MotorSpeed : INT; (* Actual spinning motor speed output *)
END_VAR

(* Internal variables for threshold values *)
VAR
    rSugarThreshold : REAL := 10.0; (* Sugar level threshold for feeding *)
    iSpeedThreshold : INT := 0; (* Speed threshold for motor activation *)
END_VAR

(* Main control logic *)
(* Sugar feeder control: Activate when sugar level is below threshold *)
SugarFeeder := SugarLevel < rSugarThreshold;

(* Motor speed control: Set to input speed if positive, otherwise 0 *)
IF SpinningSpeed > iSpeedThreshold THEN
    MotorSpeed := SpinningSpeed;
ELSE
    MotorSpeed := 0;
END_IF;

END_FUNCTION_BLOCK