FUNCTION_BLOCK TheaterControl
VAR_INPUT
    StartButton : BOOL;
    StopButton : BOOL;
    SceneNumber : INT;
END_VAR
VAR_OUTPUT
    LightingControl : BOOL;
    SoundControl : BOOL;
    PerformanceInProgress : BOOL;
END_VAR
VAR
    IsStopActive : BOOL;
    IsStartActive : BOOL;
    IsSceneValid : BOOL;
    i : INT;
END_VAR

IsStopActive := StopButton;

IF IsStopActive THEN
    LightingControl := FALSE;
    SoundControl := FALSE;
    PerformanceInProgress := FALSE;
ELSIF StartButton AND NOT PerformanceInProgress THEN
    IsSceneValid := (SceneNumber >= 1) AND (SceneNumber <= 3);
    IF IsSceneValid THEN
        LightingControl := TRUE;
        SoundControl := TRUE;
        PerformanceInProgress := TRUE;
    ELSE
        LightingControl := FALSE;
        SoundControl := FALSE;
        PerformanceInProgress := FALSE;
    END_IF;
ELSE
    LightingControl := LightingControl;
    SoundControl := SoundControl;
    PerformanceInProgress := PerformanceInProgress;
END_IF;

END_FUNCTION_BLOCK