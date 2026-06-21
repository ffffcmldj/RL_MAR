FUNCTION_BLOCK AmusementRideControl
VAR_INPUT
    StartButton : BOOL;
    StopButton : BOOL;
    SpeedSensor : REAL;
    SafetySensor : BOOL;
END_VAR
VAR_OUTPUT
    MotorOn : BOOL := FALSE;
    BrakeOn : BOOL := TRUE;
END_VAR
VAR
    SpeedLimit : REAL := 60.0;
END_VAR

IF StopButton THEN
    MotorOn := FALSE;
    BrakeOn := TRUE;
ELSE
    IF (StartButton = TRUE) AND (SpeedSensor <= SpeedLimit) AND (SafetySensor = TRUE) THEN
        MotorOn := TRUE;
        BrakeOn := FALSE;
    ELSE
        MotorOn := FALSE;
        BrakeOn := TRUE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK