FUNCTION_BLOCK MultimediaArtInstallationControl
VAR_INPUT
    MotionSensor : BOOL;
    AudioTrack : BOOL;
    VisualContent : BOOL;
END_VAR
VAR_OUTPUT
    LightingControl : BOOL;
    AudioControl : BOOL;
    VisualControl : BOOL;
END_VAR
VAR
    ActivationTimer : INT;
    MaxDuration : INT;
    SafetyFault : BOOL;
    i : INT;
END_VAR

MaxDuration := 300;
SafetyFault := FALSE;

IF SafetyFault = TRUE THEN
    LightingControl := FALSE;
    AudioControl := FALSE;
    VisualControl := FALSE;
    ActivationTimer := 0;
ELSIF MotionSensor = TRUE THEN
    LightingControl := TRUE;
    AudioControl := AudioTrack;
    VisualControl := VisualContent;
    
    ActivationTimer := ActivationTimer + 1;
    
    IF ActivationTimer >= MaxDuration THEN
        LightingControl := FALSE;
        AudioControl := FALSE;
        VisualControl := FALSE;
        ActivationTimer := 0;
    END_IF;
ELSE
    LightingControl := FALSE;
    AudioControl := FALSE;
    VisualControl := FALSE;
    ActivationTimer := 0;
END_IF;

END_FUNCTION_BLOCK