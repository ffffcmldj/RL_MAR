ructured-text
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
    state : INT := 0; (* The state variable (0 for IDLE, 1 for PERFORMANCE IN PROGRESS, 2 for STOPPING PERFORMANCE) *)
    prevState : INT; (* The previous state variable *)
    sceneValid : BOOL; (* To check if SceneNumber is valid (1 to 3) *)
    sceneNumber : INT; (* To store the valid SceneNumber *)
END_VAR

(* Implementation Logic *)
IF StopButton THEN
    state := 2; (* Transition to STOPPING PERFORMANCE *)
END_IF

CASE state OF
    0: (* IDLE State *)
        LightingControl := FALSE;
        SoundControl := FALSE;
        PerformanceInProgress := FALSE;
        
        IF StartButton AND NOT PerformanceInProgress THEN
            sceneValid := (SceneNumber >= 1) AND (SceneNumber <= 3);
            IF sceneValid THEN
                state := 1; (* Transition to PERFORMANCE IN PROGRESS *)
                sceneNumber := SceneNumber; (* Store valid SceneNumber *)
            END_IF
        END_IF

    1: (* PERFORMANCE IN PROGRESS State *)
        LightingControl := TRUE; (* Activate lighting based on SceneNumber *)
        SoundControl := TRUE; (* Activate sound based on SceneNumber *)
        PerformanceInProgress := TRUE;
        
        IF StopButton THEN
            state := 2; (* Transition to STOPPING PERFORMANCE *)
        END_IF

    2: (* STOPPING PERFORMANCE State *)
        LightingControl := FALSE;
        SoundControl := FALSE;
        PerformanceInProgress := FALSE;
        state := 0; (* Transition back to IDLE after stopping *)
END_CASE

END_FUNCTION_BLOCK
END_ST