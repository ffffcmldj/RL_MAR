plaintext
START_ST
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
    state : INT := 0; (* Current state of the system *)
    prevState : INT := 0; (* Previous state of the system *)
END_VAR

(* State Definitions *)
(* STATE 0: IDLE *)
(* STATE 1: RUNNING *)
(* STATE 2: EMERGENCY_STOP *)
(* STATE 3: JAM_DETECTED *)

(* State Machine Logic *)
CASE state OF
    0: (* IDLE *)
        MotorControl := FALSE;
        SafetyRelay := TRUE;

        (* Transition to RUNNING *)
        IF (StartButton OR MaterialInFeed) AND NOT EmergencyStop AND NOT JammedSensor THEN
            prevState := state;
            state := 1;
        END_IF;

    1: (* RUNNING *)
        MotorControl := TRUE;
        SafetyRelay := TRUE;

        (* Transition to IDLE *)
        IF StopButton AND NOT EmergencyStop AND NOT JammedSensor THEN
            prevState := state;
            state := 0;
        END_IF;

        (* Transition to EMERGENCY_STOP *)
        IF EmergencyStop THEN
            prevState := state;
            state := 2;
        END_IF;

        (* Transition to JAM_DETECTED *)
        IF JammedSensor THEN
            prevState := state;
            state := 3;
        END_IF;

    2: (* EMERGENCY_STOP *)
        MotorControl := FALSE;
        SafetyRelay := FALSE;

        (* Transition to IDLE *)
        IF NOT EmergencyStop AND NOT JammedSensor THEN
            prevState := state;
            state := 0;
        END_IF;

    3: (* JAM_DETECTED *)
        MotorControl := FALSE;
        SafetyRelay := FALSE;

        (* Transition to IDLE *)
        IF NOT EmergencyStop AND NOT JammedSensor THEN
            prevState := state;
            state := 0;
        END_IF;

    ELSE
        (* Default case to handle unexpected states *)
        MotorControl := FALSE;
        SafetyRelay := FALSE;
        state := 0; (* Reset to IDLE *)
END_CASE;

END_FUNCTION_BLOCK
END_ST