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
    CurrentState : INT := 1; (* 1=IDLE, 2=ACTIVE, 3=STOP *)
    NextState : INT;
END_VAR

(* State Machine Logic *)
CASE CurrentState OF
    1: (* IDLE State *)
        LightingControl := FALSE;
        SoundControl := FALSE;
        PerformanceInProgress := FALSE;
        
        IF StopButton THEN
            NextState := 3;
        ELSIF StartButton AND NOT PerformanceInProgress THEN
            IF (SceneNumber >= 1) AND (SceneNumber <= 3) THEN
                NextState := 2;
            ELSE
                NextState := 3;
            END_IF;
        ELSE
            NextState := 1;
        END_IF;
        
    2: (* ACTIVE State *)
        LightingControl := TRUE;
        SoundControl := TRUE;
        PerformanceInProgress := TRUE;
        
        IF StopButton THEN
            NextState := 3;
        ELSE
            NextState := 2;
        END_IF;
        
    3: (* STOP State *)
        LightingControl := FALSE;
        SoundControl := FALSE;
        PerformanceInProgress := FALSE;
        NextState := 1;
        
END_CASE;

(* State Transition *)
CurrentState := NextState;

END_FUNCTION_BLOCK;