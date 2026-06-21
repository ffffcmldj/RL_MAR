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
    END_VAR

    (* Main logic body *)
    IF StopButton THEN
        (* Emergency Stop - Highest Priority *)
        MotorOn := FALSE;
        BrakeOn := TRUE;
    ELSIF StartButton AND (NOT StopButton) AND (SpeedSensor <= SpeedLimit) AND SafetySensor THEN
        (* Start Condition - All Conditions Met *)
        MotorOn := TRUE;
        BrakeOn := FALSE;
    ELSE
        (* Default State - Fail-Safe *)
        MotorOn := FALSE;
        BrakeOn := TRUE;
    END_IF;

    (* Runtime Safety Monitoring *)
    IF MotorOn AND ((SpeedSensor > SpeedLimit) OR (NOT SafetySensor)) THEN
        MotorOn := FALSE;
        BrakeOn := TRUE;
    END_IF;

END_FUNCTION_BLOCK;