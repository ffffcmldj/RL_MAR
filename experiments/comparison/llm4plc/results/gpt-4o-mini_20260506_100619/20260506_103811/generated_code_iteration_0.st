ructured-text
START_ST
FUNCTION_BLOCK AmusementRideControl
VAR_INPUT
    StartButton : BOOL; (* Start button input *)
    StopButton : BOOL; (* Emergency stop button input *)
    SpeedSensor : REAL; (* Speed sensor input (RPM) *)
    SafetySensor : BOOL; (* Safety sensor status *)
END_VAR
VAR_OUTPUT
    MotorOn : BOOL := FALSE; (* Motor control output *)
    BrakeOn : BOOL := TRUE; (* Brake control output *)
END_VAR
VAR
    SpeedLimit : REAL := 60.0; (* Maximum allowed speed in RPM *)
    state : INT := 0; (* The current state variable *)
    prevState : INT := 0; (* The previous state variable (for tracking) *)
END_VAR

(* State Definitions *)
(* 0: EMERGENCY STOP *)
(* 1: INITIALIZATION *)
(* 2: START CONDITION CHECK *)
(* 3: NORMAL OPERATION *)
(* 4: DEFAULT STATE (FAIL-SAFE) *)

(* Main Control Logic *)
IF StopButton THEN
    MotorOn := FALSE;
    BrakeOn := TRUE;
    state := 0; (* Transition to EMERGENCY STOP state *)
ELSE
    CASE state OF
        0: (* EMERGENCY STOP *)
            BrakeOn := TRUE; (* Brake engaged *)
            IF NOT StopButton THEN
                state := 1; (* Transition to INITIALIZATION state *)
            END_IF;

        1: (* INITIALIZATION *)
            BrakeOn := TRUE; (* Brake engaged *)
            state := 2; (* Transition to START CONDITION CHECK state *)

        2: (* START CONDITION CHECK *)
            IF StartButton AND NOT StopButton AND (SpeedSensor <= SpeedLimit) AND SafetySensor THEN
                MotorOn := TRUE; (* Motor running *)
                BrakeOn := FALSE; (* Brake disengaged *)
                state := 3; (* Transition to NORMAL OPERATION state *)
            ELSE
                MotorOn := FALSE; (* Motor not running *)
                BrakeOn := TRUE; (* Brake engaged *)
                state := 4; (* Transition to DEFAULT STATE (FAIL-SAFE) *)
            END_IF;

        3: (* NORMAL OPERATION *)
            IF StopButton THEN
                MotorOn := FALSE;
                BrakeOn := TRUE;
                state := 0; (* Transition to EMERGENCY STOP state *)
            ELSIF SpeedSensor > SpeedLimit OR NOT SafetySensor THEN
                MotorOn := FALSE; (* Motor not running *)
                BrakeOn := TRUE; (* Brake engaged *)
                state := 4; (* Transition to DEFAULT STATE (FAIL-SAFE) *)
            END_IF;

        4: (* DEFAULT STATE (FAIL-SAFE) *)
            MotorOn := FALSE; (* Motor not running *)
            BrakeOn := TRUE; (* Brake engaged *)
            IF StartButton AND NOT StopButton AND (SpeedSensor <= SpeedLimit) AND SafetySensor THEN
                state := 2; (* Transition to START CONDITION CHECK state *)
            END_IF;

    END_CASE;
END_IF;

END_FUNCTION_BLOCK
END_ST