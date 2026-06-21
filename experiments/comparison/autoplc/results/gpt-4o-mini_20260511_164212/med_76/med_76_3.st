FUNCTION_BLOCK MultimediaArtInstallationControl
    VAR_INPUT
        MotionSensor : BOOL; (* Motion detection input *)
        AudioTrack : BOOL; (* Selected audio track *)
        VisualContent : BOOL; (* Selected visual content *)
    END_VAR_INPUT

    VAR_OUTPUT
        LightingControl : BOOL; (* Lighting control output *)
        AudioControl : BOOL; (* Audio playback control *)
        VisualControl : BOOL; (* Visual display control *)
    END_VAR_OUTPUT

    VAR
        ActivationTimer : INT; (* Timer for activation duration *)
        State : INT; (* State variable to track current state *)
    END_VAR

    (* State Definitions *)
    CONST
        IDLE_STATE : INT := 0;
        ACTIVE_STATE : INT := 1;
        DEACTIVATION_STATE : INT := 2;
    END_CONST

    (* Initialization *)
    IF ActivationTimer = 0 THEN
        LightingControl := FALSE;
        AudioControl := FALSE;
        VisualControl := FALSE;
        State := IDLE_STATE;
    END_IF

    (* State Machine Logic *)
    CASE State OF
        IDLE_STATE:
            IF MotionSensor THEN
                State := ACTIVE_STATE; (* Transition to Active State *)
            END_IF

        ACTIVE_STATE:
            LightingControl := TRUE; (* Activate lighting *)
            AudioControl := TRUE; (* Start audio playback *)
            VisualControl := TRUE; (* Activate visual content *)

            (* Increment Activation Timer *)
            IF ActivationTimer < 300 THEN
                ActivationTimer := ActivationTimer + 1; (* Increment timer *)
            END_IF

            IF NOT MotionSensor THEN
                State := DEACTIVATION_STATE; (* Transition to Deactivation State *)
            END_IF

        DEACTIVATION_STATE:
            LightingControl := FALSE; (* Deactivate lighting *)
            AudioControl := FALSE; (* Stop audio playback *)
            VisualControl := FALSE; (* Deactivate visual content *)
            ActivationTimer := 0; (* Reset timer *)
            State := IDLE_STATE; (* Transition back to Idle State *)
    END_CASE
END_FUNCTION_BLOCK