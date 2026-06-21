FUNCTION_BLOCK AmusementRideControl
VAR_INPUT
    StartButton : BOOL;        (* Start button input *)
    StopButton : BOOL;         (* Emergency stop button input *)
    SpeedSensor : REAL;        (* Speed sensor input (RPM) *)
    SafetySensor : BOOL;       (* Safety sensor status *)
END_VAR
VAR_OUTPUT
    MotorOn : BOOL := FALSE;   (* Motor control output *)
    BrakeOn : BOOL := TRUE;    (* Brake control output *)
END_VAR
VAR
    SpeedLimit : REAL := 60.0; (* Maximum allowed speed in RPM *)
END_VAR

(* Emergency Stop - Highest Priority *)
IF StopButton THEN
    MotorOn := FALSE;
    BrakeOn := TRUE;
ELSE
    (* Start Condition - All Conditions Must Be Met *)
    IF StartButton AND 
       (NOT StopButton) AND 
       (SpeedSensor <= SpeedLimit) AND 
       SafetySensor THEN
        MotorOn := TRUE;
        BrakeOn := FALSE;
    ELSE
        MotorOn := FALSE;
        BrakeOn := TRUE;
    END_IF;
    
    (* Normal Operation Monitoring - Continuous Check *)
    IF MotorOn AND 
       ((SpeedSensor > SpeedLimit) OR (NOT SafetySensor)) THEN
        MotorOn := FALSE;
        BrakeOn := TRUE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK