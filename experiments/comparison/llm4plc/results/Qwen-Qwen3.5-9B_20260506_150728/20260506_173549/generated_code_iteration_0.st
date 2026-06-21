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
    state : INT; (* The FSM state variable: 0=Idle, 1=Active, 2=Timeout *)
    prevMotion : BOOL; (* Tracks previous motion state to detect loss of motion *)
    maxDuration : INT; (* Constant for 300 seconds limit *)
    ActivationTimer : INT; (* Timer for activation duration *)
    SafetyInterlock : BOOL; (* Safety protocol variable to prevent overloading *)
END_VAR
END_FUNCTION_BLOCK

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
    state : INT; (* The FSM state variable: 0=Idle, 1=Active, 2=Timeout *)
    prevMotion : BOOL; (* Tracks previous motion state to detect loss of motion *)
    maxDuration : INT; (* Constant for 300 seconds limit *)
    ActivationTimer : INT; (* Timer for activation duration *)
    SafetyInterlock : BOOL; (* Safety protocol variable to prevent overloading *)
END_VAR

BEGIN
    (* --- Initialization and Constants --- *)
    IF state = 0 THEN
        maxDuration := 300;
    END_IF;

    (* --- Safety Protocol Check --- *)
    (* Assuming SystemSafe is handled externally or by a default safe state if not provided.
       Here we assume the system is safe unless an external fault signal exists.
       If a specific safety input were available, it would be added to VAR_INPUT.
       For this implementation, we assume SafetyInterlock is TRUE by default. *)
    SafetyInterlock := TRUE; (* Default to safe state *)

    (* --- State Machine Logic --- *)

    (* State 0: IDLE (Initial) *)
    (* Description: System is waiting for motion. All outputs are OFF. Timer is reset. *)
    IF state = 0 THEN
        LightingControl := FALSE;
        AudioControl := FALSE;
        VisualControl := FALSE;
        ActivationTimer := 0;
        
        (* Transition to State 1 *)
        (* Condition: Motion detected AND Timer is at 0 (first detection) *)
        IF MotionSensor = TRUE AND ActivationTimer = 0 THEN
            state := 1;
        END_IF;

    (* State 1: ACTIVE (Motion Detected) *)
    (* Description: Motion is present. System enables Lighting, Audio, and Visuals. Timer increments. *)
    ELSEIF state = 1 THEN
        (* Check for loss of motion or timeout *)
        IF MotionSensor = FALSE OR ActivationTimer >= maxDuration THEN
            state := 2;
        END_IF;

        (* If still in Active state *)
        IF state = 1 THEN
            (* Element Activation Logic *)
            (* Lighting: Always ON when active (enhances environment) *)
            LightingControl := TRUE;
            
            (* Audio: Enabled ONLY if AudioTrack input is true *)
            AudioControl := AudioTrack;
            
            (* Visuals: Enabled ONLY if VisualContent input is true *)
            VisualControl := VisualContent;
            
            (* Increment Timer *)
            ActivationTimer := ActivationTimer + 1;
        END_IF;

    (* State 2: TIMEOUT (Motion Lost OR Limit Reached) *)
    (* Description: Motion is lost OR the 300-second limit is reached. 
       System disables all outputs and resets the timer. *)
    ELSEIF state = 2 THEN
        LightingControl := FALSE;
        AudioControl := FALSE;
        VisualControl := FALSE;
        ActivationTimer := 0;
        
        (* Transition to State 0 (Idle) for next scan cycle *)
        state := 0;
    END_IF;

    (* --- Update Previous Motion State for Next Cycle --- *)
    (* Only update prevMotion if we are not in the timeout state to avoid false resets 
       immediately after entering timeout, though the logic above handles state reset. *)
    IF state <> 2 THEN
        prevMotion := MotionSensor;
    END_IF;

END_FUNCTION_BLOCK
END_ST