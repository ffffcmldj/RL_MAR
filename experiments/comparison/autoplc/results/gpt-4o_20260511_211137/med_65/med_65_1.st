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
        ValidScene : BOOL; (* Internal flag to check if the scene is valid *)
    END_VAR

    (* Initialization: Set all outputs to FALSE *)
    LightingControl := FALSE;
    SoundControl := FALSE;
    PerformanceInProgress := FALSE;

    (* Start/Stop Control Logic *)
    IF StopButton THEN
        (* Stop button pressed: Immediately halt performance *)
        LightingControl := FALSE;
        SoundControl := FALSE;
        PerformanceInProgress := FALSE;
    ELSE
        (* Check if StartButton is pressed and no performance is in progress *)
        IF StartButton AND NOT PerformanceInProgress THEN
            (* Check if the SceneNumber is valid (1, 2, or 3) *)
            IF (SceneNumber >= 1) AND (SceneNumber <= 3) THEN
                ValidScene := TRUE;
            ELSE
                ValidScene := FALSE;
            END_IF;

            (* Scene Selection and Activation *)
            IF ValidScene THEN
                LightingControl := TRUE;
                SoundControl := TRUE;
                PerformanceInProgress := TRUE;
            ELSE
                LightingControl := FALSE;
                SoundControl := FALSE;
                PerformanceInProgress := FALSE;
            END_IF;
        END_IF;
    END_IF;
END_FUNCTION_BLOCK