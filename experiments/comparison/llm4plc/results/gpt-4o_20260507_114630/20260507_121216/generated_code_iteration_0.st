```pascal
START_ST
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
    state : INT; (* Current state of the system *)
    prevState : INT; (* Previous state of the system *)
END_VAR

(* Initialize outputs and states *)
IF NOT (StartButton OR StopButton) THEN
    IF state = 0 THEN
        (* STATE 0: IDLE *)
        LightingControl := FALSE;
        SoundControl := FALSE;
        PerformanceInProgress := FALSE;
        IF StartButton THEN
            state := 1;
        END_IF;
ENDIF
END_ST