ructured-text
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
    state : INT; (* State variable *)
END_VAR

(* INITIALIZE STATE *)
state := 0;

(* STATE MANAGEMENT LOGIC *)
CASE state OF
    0: (* INITIALIZE *)
        SugarFeeder := FALSE;
        MotorSpeed := 0;
        state := 1; (* Transition to CONTROL_SUGAR_FEEDER *)

    1: (* CONTROL_SUGAR_FEEDER *)
        IF SugarLevel < 10.0 THEN
            SugarFeeder := TRUE;
        ELSE
            SugarFeeder := FALSE;
            state := 2; (* Transition to CONTROL_MOTOR_SPEED *)
        END_IF

    2: (* CONTROL_MOTOR_SPEED *)
        IF SpinningSpeed > 0 THEN
            MotorSpeed := SpinningSpeed;
        ELSE
            MotorSpeed := 0;
        END_IF
        (* Stay in this state until conditions change *)
END_CASE

END_FUNCTION_BLOCK