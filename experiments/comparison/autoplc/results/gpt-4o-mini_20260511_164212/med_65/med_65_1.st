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
        ValidScene : BOOL; (* Indicator for valid scene number *)
    END_VAR

    (* Initialization *)
    LightingControl := FALSE;
    SoundControl := FALSE;
    PerformanceInProgress := FALSE;
    ValidScene := FALSE;

    (* Check if StopButton is pressed *)
    IF StopButton THEN
        LightingControl := FALSE;
        SoundControl := FALSE;
        PerformanceInProgress := FALSE;
    ELSE
        (* Check if StartButton is pressed *)
        IF StartButton AND NOT PerformanceInProgress THEN
            (* Validate SceneNumber *)
            IF SceneNumber >= 1 AND SceneNumber <= 3 THEN
                ValidScene := TRUE;
            ELSE
                ValidScene := FALSE;
            END_IF;

            (* Activate performance if the scene is valid *)
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