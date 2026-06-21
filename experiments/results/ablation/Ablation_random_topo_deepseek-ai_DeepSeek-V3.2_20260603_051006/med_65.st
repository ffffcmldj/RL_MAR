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
    CurrentState : INT := 0;   (* 0=Idle, 1=Validate Scene, 2=Performance Active *)
    NextState : INT := 0;
END_VAR

(* State machine execution *)
CurrentState := NextState;

CASE CurrentState OF
    0: (* Idle State *)
        LightingControl := FALSE;
        SoundControl := FALSE;
        PerformanceInProgress := FALSE;
        
        IF StopButton THEN
            NextState := 0;
        ELSIF StartButton AND NOT PerformanceInProgress THEN
            NextState := 1;
        ELSE
            NextState := 0;
        END_IF;
    
    1: (* Validate Scene State *)
        (* Stop button has highest priority *)
        IF StopButton THEN
            NextState := 0;
        ELSIF (SceneNumber >= 1) AND (SceneNumber <= 3) THEN
            NextState := 2;
        ELSE
            (* Invalid scene number - return to idle *)
            NextState := 0;
        END_IF;
    
    2: (* Performance Active State *)
        LightingControl := TRUE;
        SoundControl := TRUE;
        PerformanceInProgress := TRUE;
        
        IF StopButton THEN
            NextState := 0;
        ELSE
            NextState := 2;
        END_IF;
        
    ELSE
        (* Fallback to idle state for safety *)
        NextState := 0;
END_CASE;

END_FUNCTION_BLOCK