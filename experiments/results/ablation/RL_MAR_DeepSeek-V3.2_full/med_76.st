FUNCTION_BLOCK MultimediaArtInstallationControl
VAR_INPUT
    MotionSensor : BOOL; (* Motion detection input *)
    AudioTrack : BOOL; (* Selected audio track *)
    VisualContent : BOOL; (* Selected visual content *)
END_VAR

VAR_OUTPUT
    LightingControl : BOOL; (* Lighting control output *)
    AudioControl : BOOL; (* Audio playback control *)
    VisualControl : BOOL; (* Visual display control *)
    ActivationTimer : INT; (* Timer for activation duration *)
END_VAR

VAR
    bMotionDetectedPrev : BOOL; (* Previous state of motion sensor *)
    bElementsActive : BOOL; (* State of all multimedia elements *)
END_VAR

(* Main logic *)
IF MotionSensor THEN
    (* Motion detected: activate all elements *)
    LightingControl := TRUE;
    AudioControl := AudioTrack; (* Only activate if audio track is selected *)
    VisualControl := VisualContent; (* Only activate if visual content is selected *)
    bElementsActive := TRUE;
    
    (* Increment activation timer up to 300 seconds *)
    IF ActivationTimer < 300 THEN
        ActivationTimer := ActivationTimer + 1;
    END_IF;
    
    (* Store current motion state for edge detection *)
    bMotionDetectedPrev := TRUE;
    
ELSE
    (* No motion detected: deactivate all elements *)
    LightingControl := FALSE;
    AudioControl := FALSE;
    VisualControl := FALSE;
    bElementsActive := FALSE;
    
    (* Reset timer when no motion is detected *)
    ActivationTimer := 0;
    
    (* Store current motion state for edge detection *)
    bMotionDetectedPrev := FALSE;
END_IF;

(* Safety protocol: Ensure elements are only active when motion is detected *)
IF NOT MotionSensor AND bElementsActive THEN
    LightingControl := FALSE;
    AudioControl := FALSE;
    VisualControl := FALSE;
    bElementsActive := FALSE;
    ActivationTimer := 0;
END_IF;

END_FUNCTION_BLOCK