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
    bStartRisingEdge : BOOL;
    bStopRisingEdge : BOOL;
    bPrevStart : BOOL := FALSE;
    bPrevStop : BOOL := FALSE;
END_VAR

(* Detect rising edges for button presses *)
bStartRisingEdge := StartButton AND NOT bPrevStart;
bStopRisingEdge := StopButton AND NOT bPrevStop;
bPrevStart := StartButton;
bPrevStop := StopButton;

(* Main control logic with stop button having highest priority *)
IF bStopRisingEdge THEN
    (* Immediate stop - override all other inputs *)
    LightingControl := FALSE;
    SoundControl := FALSE;
    PerformanceInProgress := FALSE;
ELSIF bStartRisingEdge AND NOT PerformanceInProgress THEN
    (* Start performance only if not already in progress *)
    IF (SceneNumber >= 1) AND (SceneNumber <= 3) THEN
        (* Valid scene - activate outputs *)
        LightingControl := TRUE;
        SoundControl := TRUE;
        PerformanceInProgress := TRUE;
    ELSE
        (* Invalid scene - keep outputs inactive *)
        LightingControl := FALSE;
        SoundControl := FALSE;
        PerformanceInProgress := FALSE;
    END_IF;
END_IF;

(* Note: Outputs maintain their state until changed by the logic above *)
END_FUNCTION_BLOCK