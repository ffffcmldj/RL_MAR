FUNCTION_BLOCK AmusementRideControl
VAR_INPUT
    StartButton : BOOL;     (* Start button input *)
    StopButton : BOOL;      (* Emergency stop button input *)
    SpeedSensor : REAL;     (* Speed sensor input (RPM) *)
    SafetySensor : BOOL;    (* Safety sensor status *)
END_VAR
VAR_OUTPUT
    MotorOn : BOOL := FALSE;    (* Motor control output *)
    BrakeOn : BOOL := TRUE;     (* Brake control output *)
END_VAR
VAR
    SpeedLimit : REAL := 60.0;  (* Maximum allowed speed in RPM *)
END_VAR

(* Main safety control logic *)
IF StopButton THEN
    (* Emergency Stop - Highest Priority *)
    MotorOn := FALSE;
    BrakeOn := TRUE;
ELSIF StartButton AND (NOT StopButton) AND (SpeedSensor <= SpeedLimit) AND SafetySensor THEN
    (* Start Condition - All conditions must be met *)
    MotorOn := TRUE;
    BrakeOn := FALSE;
ELSE
    (* Default/Fail-Safe State *)
    MotorOn := FALSE;
    BrakeOn := TRUE;
END_IF;

(* Continuous monitoring during normal operation *)
IF MotorOn THEN
    IF (SpeedSensor > SpeedLimit) OR (NOT SafetySensor) THEN
        (* Safety violation during operation *)
        MotorOn := FALSE;
        BrakeOn := TRUE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK