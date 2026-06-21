FUNCTION_BLOCK ShredderControl
VAR_INPUT
    StartButton : BOOL; (* Input for the start button *)
    StopButton : BOOL; (* Input for the stop button *)
    EmergencyStop : BOOL; (* Input for the emergency stop button *)
    MaterialInFeed : BOOL; (* Input for material being fed into the shredder *)
    JammedSensor : BOOL; (* Input for detecting material jamming *)
END_VAR
VAR_OUTPUT
    MotorControl : BOOL; (* Output for controlling the shredder motor *)
    SafetyRelay : BOOL; (* Output for safety relay: TRUE=Safe, FALSE=Unsafe *)
END_VAR
VAR
    MotorRunning : BOOL; (* Internal variable to track motor running state *)
END_VAR

(* Initialize outputs *)
MotorControl := FALSE;
SafetyRelay := FALSE;
MotorRunning := FALSE;

(* Emergency Stop Logic *)
IF EmergencyStop THEN
    MotorControl := FALSE;
    SafetyRelay := FALSE;
    MotorRunning := FALSE;
ELSE
    (* Jam Detection Logic *)
    IF JammedSensor THEN
        MotorControl := FALSE;
        SafetyRelay := FALSE;
        MotorRunning := FALSE;
    ELSE
        (* Normal Operation Logic *)
        IF StartButton OR MaterialInFeed THEN
            MotorControl := TRUE;
            SafetyRelay := TRUE;
            MotorRunning := TRUE;
        ELSIF StopButton THEN
            MotorControl := FALSE;
            MotorRunning := FALSE;
        END_IF

        (* Safety Relay Logic *)
        IF MotorRunning THEN
            SafetyRelay := TRUE;
        ELSE
            SafetyRelay := FALSE;
        END_IF
    END_IF
END_IF

END_FUNCTION_BLOCK