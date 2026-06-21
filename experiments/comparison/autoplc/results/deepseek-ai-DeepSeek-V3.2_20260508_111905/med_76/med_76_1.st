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
END_VAR
VAR
    ActivationTimer : INT; (* Timer for activation duration *)
    bPrevMotionState : BOOL; (* Previous motion sensor state for edge detection *)
    bIsActiveState : BOOL; (* Current state flag: TRUE=Active, FALSE=Idle *)
    iScanCounter : INT; (* Counter for timer increments *)
    iTimerLimit : INT := 300; (* Predefined timer limit in seconds *)
END_VAR

(* Initialization and state management *)
IF NOT bPrevMotionState THEN
    (* First scan or reset condition *)
    LightingControl := FALSE;
    AudioControl := FALSE;
    VisualControl := FALSE;
    ActivationTimer := 0;
    bIsActiveState := FALSE;
    iScanCounter := 0;
END_IF

(* State transition logic *)
IF MotionSensor AND NOT bPrevMotionState THEN
    (* Rising edge detection - transition from Idle to Active *)
    bIsActiveState := TRUE;
    ActivationTimer := 0;
    iScanCounter := 0;
ELSIF NOT MotionSensor AND bPrevMotionState THEN
    (* Falling edge detection - transition from Active to Idle *)
    bIsActiveState := FALSE;
    ActivationTimer := 0;
    iScanCounter := 0;
END_IF

(* Active State Logic *)
IF bIsActiveState THEN
    (* Activate multimedia elements *)
    LightingControl := TRUE;
    AudioControl := AudioTrack;
    VisualControl := VisualContent;
    
    (* Timer increment logic - increment every second *)
    iScanCounter := iScanCounter + 1;
    
    (* Assuming 100ms scan cycle, increment timer every 10 cycles (1 second) *)
    IF iScanCounter >= 10 THEN
        ActivationTimer := ActivationTimer + 1;
        iScanCounter := 0;
        
        (* Check timer limit - safety timeout *)
        IF ActivationTimer >= iTimerLimit THEN
            bIsActiveState := FALSE;
            ActivationTimer := 0;
        END_IF;
    END_IF;
ELSE
    (* Idle State Logic *)
    LightingControl := FALSE;
    AudioControl := FALSE;
    VisualControl := FALSE;
    ActivationTimer := 0;
    iScanCounter := 0;
END_IF

(* Store current motion state for next scan *)
bPrevMotionState := MotionSensor;

END_FUNCTION_BLOCK