FUNCTION_BLOCK TheaterControl
VAR_INPUT
    StartButton : BOOL;        (* Input for starting a performance *)
    StopButton : BOOL;         (* Input for stopping a performance *)
    SceneNumber : INT;         (* Input for selecting the scene or act *)
END_VAR
VAR_OUTPUT
    LightingControl : BOOL;    (* Output for controlling lighting *)
    SoundControl : BOOL;       (* Output for controlling sound *)
    PerformanceInProgress : BOOL; (* Indicator for an ongoing performance *)
END_VAR
VAR
    bStartRisingEdge : BOOL;   (* Edge detection for start button *)
    bPrevStartState : BOOL;    (* Previous state for edge detection *)
END_VAR

(* Edge detection for StartButton *)
bStartRisingEdge := StartButton AND NOT bPrevStartState;
bPrevStartState := StartButton;

(* Main control logic *)
IF StopButton THEN
    (* Immediate stop override *)
    LightingControl := FALSE;
    SoundControl := FALSE;
    PerformanceInProgress := FALSE;
ELSIF NOT PerformanceInProgress AND bStartRisingEdge THEN
    (* Start new performance if not already in progress *)
    IF (SceneNumber >= 1) AND (SceneNumber <= 3) THEN
        LightingControl := TRUE;
        SoundControl := TRUE;
        PerformanceInProgress := TRUE;
    ELSE
        (* Invalid scene number *)
        LightingControl := FALSE;
        SoundControl := FALSE;
        PerformanceInProgress := FALSE;
    END_IF;
ELSIF PerformanceInProgress THEN
    (* Maintain performance state *)
    IF (SceneNumber >= 1) AND (SceneNumber <= 3) THEN
        LightingControl := TRUE;
        SoundControl := TRUE;
        PerformanceInProgress := TRUE;
    ELSE
        (* Scene changed to invalid during performance - stop performance *)
        LightingControl := FALSE;
        SoundControl := FALSE;
        PerformanceInProgress := FALSE;
    END_IF;
ELSE
    (* Idle state - ensure outputs are off *)
    LightingControl := FALSE;
    SoundControl := FALSE;
    PerformanceInProgress := FALSE;
END_IF;
END_FUNCTION_BLOCK