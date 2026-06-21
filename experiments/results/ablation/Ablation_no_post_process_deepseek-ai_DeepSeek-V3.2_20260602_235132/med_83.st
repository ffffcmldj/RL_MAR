FUNCTION_BLOCK AmusementRideControl
VAR_INPUT
    StartButton : BOOL;    (* Start button input *)
    StopButton : BOOL;     (* Emergency stop button input *)
    SpeedSensor : REAL;    (* Speed sensor input (RPM) *)
    SafetySensor : BOOL;   (* Safety sensor status *)
END_VAR

VAR_OUTPUT
    MotorOn : BOOL := FALSE;    (* Motor control output *)
    BrakeOn : BOOL := TRUE;     (* Brake control output *)
END_VAR

VAR
    SpeedLimit : REAL := 60.0;  (* Maximum allowed speed in RPM *)
END_VAR

(* Main safety logic implementation *)
(* Emergency Stop has ABSOLUTE highest priority *)
IF StopButton THEN
    MotorOn := FALSE;
    BrakeOn := TRUE;
    
(* Normal operation monitoring when emergency stop is NOT active *)
ELSIF MotorOn THEN
    (* Continuous monitoring during operation *)
    IF (SpeedSensor > SpeedLimit) OR (NOT SafetySensor) THEN
        MotorOn := FALSE;
        BrakeOn := TRUE;
    END_IF;
    
(* Start condition evaluation *)
ELSIF StartButton AND (NOT StopButton) AND (SpeedSensor <= SpeedLimit) AND SafetySensor THEN
    MotorOn := TRUE;
    BrakeOn := FALSE;
    
(* Default fail-safe state *)
ELSE
    MotorOn := FALSE;
    BrakeOn := TRUE;
END_IF;

END_FUNCTION_BLOCK;