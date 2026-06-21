FUNCTION_BLOCK MultimediaArtInstallationControl
VAR_INPUT
    MotionSensor : BOOL;           (* Motion detection input *)
    AudioTrack : BOOL;             (* Selected audio track *)
    VisualContent : BOOL;          (* Selected visual content *)
END_VAR

VAR_OUTPUT
    LightingControl : BOOL;        (* Lighting control output *)
    AudioControl : BOOL;           (* Audio playback control *)
    VisualControl : BOOL;          (* Visual display control *)
    ActivationTime : TIME;         (* Activation duration *)
END_VAR

VAR
    ActivationTimer : TON;         (* Timer for activation duration *)
    TimerPreset : TIME := T#300S;  (* Predefined limit: 300 seconds *)
    PreviousMotion : BOOL;         (* Edge detection for motion *)
    bMotionDetected : BOOL;        (* Internal motion detection flag *)
END_VAR

(* Initialize timer *)
ActivationTimer(IN := bMotionDetected, PT := TimerPreset);

(* Motion detection with edge detection *)
IF MotionSensor AND NOT PreviousMotion THEN
    bMotionDetected := TRUE;
ELSIF NOT MotionSensor THEN
    bMotionDetected := FALSE;
END_IF;
PreviousMotion := MotionSensor;

(* Control multimedia elements based on motion detection *)
LightingControl := bMotionDetected;
AudioControl := bMotionDetected AND AudioTrack;
VisualControl := bMotionDetected AND VisualContent;

(* Update activation time output *)
ActivationTime := ActivationTimer.ET;

(* Safety protocol: Deactivate all elements and reset timer if no motion *)
IF NOT bMotionDetected THEN
    ActivationTimer(IN := FALSE, PT := TimerPreset);
END_IF;

(* Additional safety check: Ensure elements are off when timer reaches preset *)
IF ActivationTimer.Q THEN
    bMotionDetected := FALSE;
    ActivationTimer(IN := FALSE, PT := TimerPreset);
END_IF;
END_FUNCTION_BLOCK