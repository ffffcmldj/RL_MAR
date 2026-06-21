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
    bMotionDetectedPrev : BOOL; (* Previous state of motion sensor for edge detection *)
    bElementsActive : BOOL; (* Flag indicating if elements are currently active *)
    tActivationTime : TIME; (* Activation time accumulator *)
    tNoMotionTime : TIME; (* No motion time accumulator *)
    bSafetyCheckOK : BOOL; (* Safety check status *)
END_VAR

VAR CONSTANT
    MAX_ACTIVATION_TIME : TIME := T#300S; (* Maximum activation time: 300 seconds *)
    DEBOUNCE_TIME : TIME := T#500MS; (* Debounce time for motion sensor *)
    SAFETY_CHECK_INTERVAL : TIME := T#10S; (* Interval for safety checks *)
END_VAR

(* Main control logic *)
IF NOT bSafetyCheckOK THEN
    (* Safety check failed - deactivate all elements *)
    LightingControl := FALSE;
    AudioControl := FALSE;
    VisualControl := FALSE;
    ActivationTimer := 0;
    tActivationTime := T#0S;
    tNoMotionTime := T#0S;
    bElementsActive := FALSE;
ELSE
    (* Edge detection for motion sensor with debouncing *)
    IF MotionSensor AND NOT bMotionDetectedPrev THEN
        (* Rising edge detected - start debounce timer *)
        tNoMotionTime := T#0S;
    ELSIF NOT MotionSensor AND bMotionDetectedPrev THEN
        (* Falling edge detected - start debounce timer *)
        tNoMotionTime := T#0S;
    END_IF;
    
    (* Update previous state *)
    bMotionDetectedPrev := MotionSensor;
    
    (* Check if motion is consistently detected for debounce time *)
    IF MotionSensor AND (tNoMotionTime >= DEBOUNCE_TIME) THEN
        (* Valid motion detected - activate elements *)
        IF NOT bElementsActive THEN
            (* Only activate if elements were not already active *)
            bElementsActive := TRUE;
            tActivationTime := T#0S;
        END_IF;
    ELSIF NOT MotionSensor AND (tNoMotionTime >= DEBOUNCE_TIME) THEN
        (* No motion detected for debounce time - deactivate elements *)
        bElementsActive := FALSE;
        tActivationTime := T#0S;
    END_IF;
    
    (* Control multimedia elements based on activation state and safety *)
    IF bElementsActive AND (tActivationTime < MAX_ACTIVATION_TIME) THEN
        (* Activate all elements *)
        LightingControl := TRUE;
        AudioControl := AudioTrack; (* Only activate if audio track is selected *)
        VisualControl := VisualContent; (* Only activate if visual content is selected *)
        
        (* Increment activation timer *)
        tActivationTime := tActivationTime + T#1S;
        ActivationTimer := TIME_TO_INT(tActivationTime);
    ELSE
        (* Deactivate all elements *)
        LightingControl := FALSE;
        AudioControl := FALSE;
        VisualControl := FALSE;
        
        (* Reset timer if elements are not active *)
        IF NOT bElementsActive THEN
            ActivationTimer := 0;
            tActivationTime := T#0S;
        END_IF;
    END_IF;
    
    (* Increment no motion timer when no motion is detected *)
    IF NOT MotionSensor THEN
        tNoMotionTime := tNoMotionTime + T#1S;
    ELSE
        tNoMotionTime := T#0S;
    END_IF;
    
    (* Safety protocol: Check power usage and system status *)
    (* This is a placeholder for actual safety checks *)
    bSafetyCheckOK := TRUE; (* Replace with actual safety logic *)
    
    (* Additional safety: Force deactivation if maximum time reached *)
    IF tActivationTime >= MAX_ACTIVATION_TIME THEN
        bElementsActive := FALSE;
        LightingControl := FALSE;
        AudioControl := FALSE;
        VisualControl := FALSE;
    END_IF;
END_IF;
END_FUNCTION_BLOCK