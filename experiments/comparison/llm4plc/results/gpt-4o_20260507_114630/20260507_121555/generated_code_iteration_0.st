plaintext
START_ST
FUNCTION_BLOCK MultimediaArtInstallationControl
VAR_INPUT
    MotionSensor : BOOL; (* Motion detection input *)
END_VAR
VAR_OUTPUT
    LightingControl : BOOL; (* Lighting control output *)
    AudioControl : BOOL; (* Audio playback control *)
    VisualControl : BOOL; (* Visual display control *)
END_VAR
VAR
    state : INT := 0; (* Current state of the system *)
    prevState : INT := 0; (* Previous state of the system *)
    ActivationTimer : INT := 0; (* Timer for activation duration *)
    MAX_ACTIVATION_TIME : INT := 300; (* Maximum activation time in seconds *)
END_VAR

(* State Definitions *)
(* STATE 0: IDLE *)
(* STATE 1: ACTIVATION *)
(* STATE 2: MAINTAIN ACTIVATION *)
(* STATE 3: DEACTIVATION *)

(* Main Logic *)
IF state = 0 THEN
    (* IDLE State *)
    LightingControl := FALSE;
    AudioControl := FALSE;
    VisualControl := FALSE;
    ActivationTimer := 0;

    (* Transition to ACTIVATION State *)
    IF MotionSensor = TRUE THEN
        prevState := state;
        state := 1;
    END_IF;

ELSIF state = 1 THEN
    (* ACTIVATION State *)
    LightingControl := TRUE;
    AudioControl := TRUE;
    VisualControl := TRUE;
    ActivationTimer := ActivationTimer + 1;

    (* Transition to MAINTAIN ACTIVATION State *)
    IF MotionSensor = TRUE AND ActivationTimer < MAX_ACTIVATION_TIME THEN
        prevState := state;
        state := 2;
    END_IF;

ELSIF state = 2 THEN
    (* MAINTAIN ACTIVATION State *)
    LightingControl := TRUE;
    AudioControl := TRUE;
    VisualControl := TRUE;
    ActivationTimer := ActivationTimer + 1;

    (* Transition to DEACTIVATION State *)
    IF MotionSensor = FALSE OR ActivationTimer >= MAX_ACTIVATION_TIME THEN
        prevState := state;
        state := 3;
    END_IF;

ELSIF state = 3 THEN
    (* DEACTIVATION State *)
    LightingControl := FALSE;
    AudioControl := FALSE;
    VisualControl := FALSE;
    ActivationTimer := 0;

    (* Transition to IDLE State *)
    IF MotionSensor = FALSE THEN
        prevState := state;
        state := 0;
    END_IF;

END_IF;

END_FUNCTION_BLOCK
END_ST