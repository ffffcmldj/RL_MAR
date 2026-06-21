FUNCTION_BLOCK TheaterControl
VAR_INPUT
    StartButton : BOOL;         (* Rising edge triggers start if conditions met *)
    StopButton : BOOL;          (* Immediate stop, overrides all other inputs *)
    SceneNumber : INT;          (* Valid range: 1-3 *)
END_VAR

VAR_OUTPUT
    LightingControl : BOOL;     (* Controls theater lighting system *)
    SoundControl : BOOL;        (* Controls theater sound system *)
    PerformanceInProgress : BOOL; (* Indicates active performance *)
END_VAR

VAR
    (* Internal state tracking *)
    bPerformanceActive : BOOL := FALSE;
    bStartRisingEdge : BOOL := FALSE;
    bPrevStartButton : BOOL := FALSE;
END_VAR

(* Rising edge detection for StartButton *)
bStartRisingEdge := StartButton AND NOT bPrevStartButton;
bPrevStartButton := StartButton;

(* Immediate stop override - highest priority *)
IF StopButton THEN
    bPerformanceActive := FALSE;
    LightingControl := FALSE;
    SoundControl := FALSE;
    PerformanceInProgress := FALSE;
    
(* Start performance when conditions are met *)
ELSIF bStartRisingEdge AND NOT bPerformanceActive THEN
    IF (SceneNumber >= 1) AND (SceneNumber <= 3) THEN
        bPerformanceActive := TRUE;
        LightingControl := TRUE;
        SoundControl := TRUE;
        PerformanceInProgress := TRUE;
    ELSE
        (* Invalid scene number - maintain stopped state *)
        bPerformanceActive := FALSE;
        LightingControl := FALSE;
        SoundControl := FALSE;
        PerformanceInProgress := FALSE;
    END_IF;
    
(* Maintain performance state while active *)
ELSIF bPerformanceActive THEN
    LightingControl := TRUE;
    SoundControl := TRUE;
    PerformanceInProgress := TRUE;
    
(* Default state - no performance active *)
ELSE
    bPerformanceActive := FALSE;
    LightingControl := FALSE;
    SoundControl := FALSE;
    PerformanceInProgress := FALSE;
END_IF;

END_FUNCTION_BLOCK;