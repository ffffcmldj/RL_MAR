FUNCTION_BLOCK ShredderControl
VAR_INPUT
    StartButton : BOOL;         (* Momentary start button *)
    StopButton : BOOL;          (* Momentary stop button *)
    EmergencyStop : BOOL;       (* Emergency stop button - active HIGH *)
    MaterialInFeed : BOOL;      (* Material detection sensor *)
    JammedSensor : BOOL;        (* Jam detection sensor - active HIGH *)
END_VAR
VAR_OUTPUT
    MotorControl : BOOL;        (* Motor contactor control *)
    SafetyRelay : BOOL;         (* Safety relay control *)
END_VAR
VAR
    bMotorRunCmd : BOOL;        (* Internal motor run command *)
    bStartEdge : BOOL;          (* Edge detection for start button *)
    bPrevStart : BOOL;          (* Previous start button state *)
    bSafetyOK : BOOL;           (* Combined safety condition *)
END_VAR

(* Edge detection for start button *)
bStartEdge := StartButton AND NOT bPrevStart;
bPrevStart := StartButton;

(* Highest priority safety condition - Emergency Stop OR Jam detected *)
bSafetyOK := NOT EmergencyStop AND NOT JammedSensor;

(* Safety Relay control - active only when safety conditions are met *)
SafetyRelay := bSafetyOK;

(* Normal operation logic - only executed when safety conditions are OK *)
IF bSafetyOK THEN
    (* Start command from button (rising edge) or material feed *)
    IF bStartEdge OR MaterialInFeed THEN
        bMotorRunCmd := TRUE;
    END_IF;
    
    (* Stop command from stop button *)
    IF StopButton THEN
        bMotorRunCmd := FALSE;
    END_IF;
ELSE
    (* Safety condition violated - force motor stop *)
    bMotorRunCmd := FALSE;
END_IF;

(* Final motor control - requires both run command AND safety OK *)
MotorControl := bMotorRunCmd AND bSafetyOK;

END_FUNCTION_BLOCK