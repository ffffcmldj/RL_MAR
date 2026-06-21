FUNCTION_BLOCK AmusementRideControl
VAR_INPUT
    StartButton : BOOL;        (* Start button input *)
    StopButton : BOOL;         (* Emergency stop button input *)
    SpeedSensor : REAL;        (* Speed sensor input (RPM) *)
    SafetySensor : BOOL;       (* Safety sensor status *)
    ResetButton : BOOL;        (* Manual reset button - required after safety trips *)
END_VAR
VAR_OUTPUT
    MotorOn : BOOL := FALSE;   (* Motor control output *)
    BrakeOn : BOOL := TRUE;    (* Brake control output - default fail-safe *)
END_VAR
VAR
    SpeedLimit : REAL := 60.0; (* Maximum allowed speed in RPM *)
    SafetyTrip : BOOL := FALSE;(* Latched safety sensor trip *)
    OverspeedTrip : BOOL := FALSE; (* Latched overspeed trip *)
    EmergencyStopActive : BOOL := FALSE; (* Emergency stop status *)
END_VAR

(* Main safety logic - executed each scan cycle *)
(* HIGHEST PRIORITY: Emergency Stop Handling *)
IF StopButton THEN
    EmergencyStopActive := TRUE;
    MotorOn := FALSE;
    BrakeOn := TRUE;
    (* Emergency stop overrides all other logic *)
    RETURN; (* Exit logic execution for this scan *)
ELSE
    EmergencyStopActive := FALSE;
END_IF;

(* Check for safety violations during operation *)
IF MotorOn THEN
    (* Continuous monitoring while motor is running *)
    IF SpeedSensor > SpeedLimit THEN
        OverspeedTrip := TRUE;
    END_IF;
    
    IF NOT SafetySensor THEN
        SafetyTrip := TRUE;
    END_IF;
END_IF;

(* Safety Trip Response - Second Highest Priority *)
IF OverspeedTrip OR SafetyTrip THEN
    MotorOn := FALSE;
    BrakeOn := TRUE;
    (* Safety trips require manual reset - do not auto-restart *)
    RETURN; (* Exit logic execution for this scan *)
END_IF;

(* Manual Reset Logic *)
IF ResetButton AND NOT MotorOn THEN
    OverspeedTrip := FALSE;
    SafetyTrip := FALSE;
END_IF;

(* START CONDITION: All conditions must be met simultaneously *)
(* Requires manual reset after any trip *)
IF StartButton 
   AND NOT StopButton 
   AND (SpeedSensor <= SpeedLimit) 
   AND SafetySensor
   AND NOT OverspeedTrip
   AND NOT SafetyTrip
   AND NOT EmergencyStopActive THEN
    (* All start conditions satisfied *)
    MotorOn := TRUE;
    BrakeOn := FALSE;
ELSE
    (* Default fail-safe state *)
    MotorOn := FALSE;
    BrakeOn := TRUE;
END_IF;

END_FUNCTION_BLOCK