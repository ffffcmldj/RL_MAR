FUNCTION_BLOCK ShredderControl
VAR_INPUT
    StartButton : BOOL;        (* Input for the start button *)
    StopButton : BOOL;         (* Input for the stop button *)
    EmergencyStop : BOOL;      (* Input for the emergency stop button *)
    MotorStatus : BOOL;        (* Feedback status of the shredder motor *)
    MaterialInFeed : BOOL;     (* Input for material being fed into the shredder *)
    JammedSensor : BOOL;       (* Input for detecting material jamming *)
END_VAR
VAR_OUTPUT
    MotorControl : BOOL;       (* Output for controlling the shredder motor *)
    SafetyRelay : BOOL;        (* Output for safety relay: TRUE=Safe, FALSE=Unsafe *)
END_VAR
VAR
    bMotorRunCmd : BOOL;       (* Internal motor run command *)
    bEmergencyCondition : BOOL; (* Combined emergency condition *)
END_VAR

(* Check for highest priority emergency conditions *)
bEmergencyCondition := EmergencyStop OR JammedSensor;

IF bEmergencyCondition THEN
    (* Emergency stop or jam detected - immediate shutdown *)
    bMotorRunCmd := FALSE;
    SafetyRelay := FALSE;
    MotorControl := FALSE;
ELSE
    (* Normal operation logic *)
    
    (* Start conditions: start button OR material feed (with no stop command) *)
    IF StartButton OR (MaterialInFeed AND NOT StopButton) THEN
        bMotorRunCmd := TRUE;
    END_IF;
    
    (* Stop condition: stop button *)
    IF StopButton THEN
        bMotorRunCmd := FALSE;
    END_IF;
    
    (* Safety relay active during normal operation *)
    SafetyRelay := TRUE;
    
    (* Control motor based on run command *)
    MotorControl := bMotorRunCmd;
END_IF;

END_FUNCTION_BLOCK