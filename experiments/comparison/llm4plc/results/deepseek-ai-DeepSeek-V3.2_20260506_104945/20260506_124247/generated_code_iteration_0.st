START_ST
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
    state : INT; (* Current state: 0 = IDLE_WAITING_FOR_MOTION, 1 = ACTIVE_ELEMENTS_ON *)
    prevState : INT; (* Previous state for detecting state changes *)
END_VAR

(* State definitions *)
CONST
    STATE_IDLE := 0;
    STATE_ACTIVE := 1;
END_CONST

(* State machine execution *)
CASE state OF
    STATE_IDLE: (* IDLE_WAITING_FOR_MOTION *)
        (* Set outputs to FALSE *)
        LightingControl := FALSE;
        AudioControl := FALSE;
        VisualControl := FALSE;
        
        (* Check transition to ACTIVE_ELEMENTS_ON *)
        IF MotionSensor THEN
            (* Reset timer and transition to active state *)
            ActivationTimer := 0;
            state := STATE_ACTIVE;
        END_IF;
        
    STATE_ACTIVE: (* ACTIVE_ELEMENTS_ON *)
        (* Set outputs to TRUE *)
        LightingControl := TRUE;
        AudioControl := TRUE;
        VisualControl := TRUE;
        
        (* Increment activation timer each cycle *)
        ActivationTimer := ActivationTimer + 1;
        
        (* Check transition back to IDLE *)
        IF (NOT MotionSensor) OR (ActivationTimer >= 300) THEN
            (* Reset timer and transition to idle state *)
            ActivationTimer := 0;
            state := STATE_IDLE;
        END_IF;
        
END_CASE;

(* Store current state for next cycle *)
prevState := state;

END_FUNCTION_BLOCK
END_ST