FUNCTION_BLOCK TheaterControl
VAR_INPUT
    StartButton : BOOL; (* Input for starting a performance *)
    StopButton : BOOL; (* Input for stopping a performance *)
    SceneNumber : INT; (* Input for selecting the scene or act *)
END_VAR

VAR_OUTPUT
    LightingControl : BOOL; (* Output for controlling lighting *)
    SoundControl : BOOL; (* Output for controlling sound *)
    PerformanceInProgress : BOOL; (* Indicator for an ongoing performance *)
END_VAR

VAR
    bStartRisingEdge : BOOL; (* Detects rising edge of StartButton *)
    bPrevStartState : BOOL; (* Previous state for edge detection *)
END_VAR

(* Rising edge detection for StartButton *)
bStartRisingEdge := StartButton AND NOT bPrevStartState;
bPrevStartState := StartButton;

(* Main control logic with StopButton as highest priority *)
IF StopButton THEN
    (* Immediate halt: override all other inputs *)
    PerformanceInProgress := FALSE;
    LightingControl := FALSE;
    SoundControl := FALSE;
ELSIF bStartRisingEdge AND NOT PerformanceInProgress THEN
    (* Start attempt when not already in progress *)
    IF (SceneNumber >= 1) AND (SceneNumber <= 3) THEN
        (* Valid scene: activate performance *)
        PerformanceInProgress := TRUE;
        LightingControl := TRUE;
        SoundControl := TRUE;
    ELSE
        (* Invalid scene: ensure all outputs are FALSE *)
        PerformanceInProgress := FALSE;
        LightingControl := FALSE;
        SoundControl := FALSE;
    END_IF;
END_IF;

(* Note: Once started, outputs remain TRUE until StopButton is pressed.
   The PerformanceInProgress state persists between cycles, 
   preventing re-triggering while active. *)
END_FUNCTION_BLOCK;