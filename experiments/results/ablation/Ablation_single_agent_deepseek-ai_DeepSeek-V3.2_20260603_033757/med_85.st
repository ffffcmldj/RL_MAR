FUNCTION_BLOCK ShredderControl
VAR_INPUT
    StartButton : BOOL;         (* Momentary start button *)
    StopButton : BOOL;          (* Momentary stop button *)
    EmergencyStop : BOOL;       (* Emergency stop button - active high *)
    MaterialInFeed : BOOL;      (* Sensor detecting material at infeed *)
    JammedSensor : BOOL;        (* Sensor detecting jam condition - active high *)
END_VAR
VAR_OUTPUT
    MotorControl : BOOL;        (* Control signal to motor starter *)
    SafetyRelay : BOOL;         (* Safety relay control *)
END_VAR
VAR
    bMotorRunning : BOOL;       (* Internal motor running state *)
    bSafetyCondition : BOOL;    (* Internal safety status *)
END_VAR

(* 1. Safety Logic - Highest Priority *)
(* Emergency stop OR jam detection deactivates safety *)
bSafetyCondition := NOT EmergencyStop AND NOT JammedSensor;
SafetyRelay := bSafetyCondition;

(* 2. Motor Control Logic *)
IF bSafetyCondition THEN
    (* Normal operation allowed *)
    
    (* Start conditions: 
       1. Start button pressed (momentary)
       2. Material detected at infeed (auto-start) *)
    IF StartButton OR MaterialInFeed THEN
        bMotorRunning := TRUE;
    END_IF;
    
    (* Stop condition: Stop button pressed (momentary) *)
    IF StopButton THEN
        bMotorRunning := FALSE;
    END_IF;
    
    (* Apply motor command *)
    MotorControl := bMotorRunning;
ELSE
    (* Safety override: Emergency stop or jam detected *)
    MotorControl := FALSE;
    bMotorRunning := FALSE;
END_IF;

END_FUNCTION_BLOCK