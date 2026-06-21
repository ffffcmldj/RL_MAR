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
    StartButtonPrev : BOOL; (* Previous state of StartButton for edge detection *)
    InternalPerformanceActive : BOOL; (* Internal state tracking *)
    bFirstCycle : BOOL := TRUE; (* First cycle flag for initialization *)
END_VAR

(* Initialize on first scan *)
IF bFirstCycle THEN
    LightingControl := FALSE;
    SoundControl := FALSE;
    PerformanceInProgress := FALSE;
    StartButtonPrev := FALSE;
    InternalPerformanceActive := FALSE;
    bFirstCycle := FALSE;
END_IF

(* Stop button has highest priority - immediate override *)
IF StopButton THEN
    LightingControl := FALSE;
    SoundControl := FALSE;
    PerformanceInProgress := FALSE;
    InternalPerformanceActive := FALSE;
ELSE
    (* Detect rising edge of StartButton *)
    IF StartButton AND NOT StartButtonPrev THEN
        (* Check if no performance is in progress *)
        IF NOT InternalPerformanceActive THEN
            (* Validate SceneNumber *)
            IF (SceneNumber >= 1) AND (SceneNumber <= 3) THEN
                (* Valid scene - activate performance *)
                LightingControl := TRUE;
                SoundControl := TRUE;
                PerformanceInProgress := TRUE;
                InternalPerformanceActive := TRUE;
            ELSE
                (* Invalid scene - remain idle *)
                LightingControl := FALSE;
                SoundControl := FALSE;
                PerformanceInProgress := FALSE;
                InternalPerformanceActive := FALSE;
            END_IF;
        END_IF;
    END_IF;
    
    (* If no start button was pressed, maintain current state *)
    (* The outputs are already set from previous logic or initialization *)
END_IF;

(* Update previous state for edge detection *)
StartButtonPrev := StartButton;

END_FUNCTION_BLOCK