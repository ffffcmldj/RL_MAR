FUNCTION_BLOCK ShredderControl
VAR_INPUT
    StartButton : BOOL; (* Input for the start button *)
    StopButton : BOOL; (* Input for the stop button *)
    EmergencyStop : BOOL; (* Input for the emergency stop button *)
    MotorStatus : BOOL; (* Feedback status of the shredder motor *)
    MaterialInFeed : BOOL; (* Input for material being fed into the shredder *)
    JammedSensor : BOOL; (* Input for detecting material jamming *)
END_VAR
VAR_OUTPUT
    MotorControl : BOOL; (* Output for controlling the shredder motor *)
    SafetyRelay : BOOL; (* Output for safety relay: TRUE=Safe, FALSE=Unsafe *)
END_VAR
VAR
    bMotorRunning : BOOL; (* Internal flag for motor running state *)
    bEmergencyCondition : BOOL; (* Internal flag for emergency condition *)
    bStartButtonPrev : BOOL; (* Previous state of StartButton for edge detection *)
    bStopButtonPrev : BOOL; (* Previous state of StopButton for edge detection *)
    bStartRisingEdge : BOOL; (* Moved from local VAR block inside code *)
    bStopRisingEdge : BOOL;  (* Moved from local VAR block inside code *)
END_VAR

(* Initialize outputs and internal variables *)
MotorControl := FALSE;
SafetyRelay := FALSE;
bMotorRunning := FALSE;
bEmergencyCondition := FALSE;
bStartButtonPrev := FALSE;
bStopButtonPrev := FALSE;
bStartRisingEdge := FALSE;
bStopRisingEdge := FALSE;

(* Check for emergency conditions - highest priority *)
IF EmergencyStop OR JammedSensor THEN
    bEmergencyCondition := TRUE;
    MotorControl := FALSE;
    SafetyRelay := FALSE;
    bMotorRunning := FALSE;
    RETURN; (* Exit immediately when emergency condition exists *)
ELSE
    bEmergencyCondition := FALSE;
END_IF

(* Edge detection for buttons *)
bStartRisingEdge := StartButton AND NOT bStartButtonPrev;
bStopRisingEdge := StopButton AND NOT bStopButtonPrev;

(* Update previous button states for next scan *)
bStartButtonPrev := StartButton;
bStopButtonPrev := StopButton;

(* Main control logic when no emergency condition exists *)
IF NOT bEmergencyCondition THEN
    (* Motor start conditions *)
    IF NOT bMotorRunning THEN
        IF bStartRisingEdge OR MaterialInFeed THEN
            bMotorRunning := TRUE;
            MotorControl := TRUE;
            SafetyRelay := TRUE;
        END_IF
    END_IF
    
    (* Motor stop conditions *)
    IF bMotorRunning THEN
        IF bStopRisingEdge THEN
            bMotorRunning := FALSE;
            MotorControl := FALSE;
            SafetyRelay := FALSE;
        END_IF
    END_IF
END_IF

(* Ensure SafetyRelay is active when motor is running *)
IF bMotorRunning THEN
    SafetyRelay := TRUE;
END_IF

END_FUNCTION_BLOCK