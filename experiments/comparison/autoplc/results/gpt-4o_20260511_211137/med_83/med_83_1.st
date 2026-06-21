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

VAR
    AllStartConditionsMet : BOOL := FALSE; (* Internal flag to check all start conditions *)
END_VAR

(* Main control logic *)
IF StopButton THEN
    (* Emergency Stop State *)
    MotorOn := FALSE;
    BrakeOn := TRUE;
ELSE
    (* Check Start Conditions *)
    AllStartConditionsMet := StartButton AND NOT StopButton AND (SpeedSensor <= SpeedLimit) AND SafetySensor;
    
    IF AllStartConditionsMet THEN
        (* Start Condition State *)
        MotorOn := TRUE;
        BrakeOn := FALSE;
    ELSE
        (* Default State (Fail-Safe) *)
        MotorOn := FALSE;
        BrakeOn := TRUE;
    END_IF;
    
    (* Normal Operation Monitoring *)
    IF MotorOn THEN
        IF (SpeedSensor > SpeedLimit) OR NOT SafetySensor THEN
            (* Transition to Default State if conditions are violated *)
            MotorOn := FALSE;
            BrakeOn := TRUE;
        END_IF;
    END_IF;
END_IF;
END_FUNCTION_BLOCK