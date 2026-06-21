START_REASON
The error occurred because the code contained a syntax issue where a semicolon was expected instead of the `STATE_INITIALIZE` keyword in the CASE statement. This is a common mistake in structured text programming where the syntax must strictly adhere to the expected format. Additionally, the variable sections were incorrectly closed with "END_VAR_OUTPUT" and "END_VAR_INPUT" instead of "END_VAR". The code structure must be maintained as a FUNCTION_BLOCK and the variable sections must be properly defined and closed.
END_REASON

START_ST
FUNCTION_BLOCK ShredderControl
VAR_INPUT
    StartButton : BOOL; (* Input for the start button *)
    StopButton : BOOL; (* Input for the stop button *)
    EmergencyStop : BOOL; (* Input for the emergency stop button *)
    MotorStatus : BOOL; (* Feedback status of the shredder motor *)
    MaterialInFeed : BOOL; (* Input for material being fed into the shredder *)
    JammedSensor : BOOL; (* Input for detecting material jamming *)
END_VAR

VAR_OUTPUT
    MotorControl : BOOL; (* Output for controlling the shredder motor *)
    SafetyRelay : BOOL; (* Output for safety relay: TRUE=Safe, FALSE=Unsafe *)
END_VAR

VAR
    state : INT; (* The state variable *)
    prevState : INT; (* The previous state variable *)
END_VAR

(* Initialize outputs *)
MotorControl := FALSE;
SafetyRelay := FALSE;

(* State Definitions *)
CONST
    STATE_INITIALIZE : INT := 0;
    STATE_EMERGENCY_STOP : INT := 1;
    STATE_JAM_DETECTED : INT := 2;
    STATE_READY_TO_RUN : INT := 3;
    STATE_RUNNING : INT := 4;
END_CONST

(* State Machine Logic *)
CASE state OF
    STATE_INITIALIZE:
        IF EmergencyStop THEN
            state := STATE_EMERGENCY_STOP;
        ELSIF JammedSensor THEN
            state := STATE_JAM_DETECTED;
        ELSIF StartButton AND MaterialInFeed THEN
            state := STATE_READY_TO_RUN;
        END_IF;
        MotorControl := FALSE;
        SafetyRelay := FALSE;

    STATE_EMERGENCY_STOP:
        IF NOT EmergencyStop THEN
            state := STATE_INITIALIZE;
        END_IF;
        MotorControl := FALSE;
        SafetyRelay := FALSE;

    STATE_JAM_DETECTED:
        IF NOT JammedSensor THEN
            state := STATE_INITIALIZE;
        END_IF;
        MotorControl := FALSE;
        SafetyRelay := FALSE;

    STATE_READY_TO_RUN:
        IF MaterialInFeed AND NOT EmergencyStop AND NOT JammedSensor THEN
            state := STATE_RUNNING;
        ELSIF StopButton THEN
            state := STATE_INITIALIZE;
        END_IF;
        MotorControl := FALSE;
        SafetyRelay := TRUE;

    STATE_RUNNING:
        IF EmergencyStop THEN
            state := STATE_EMERGENCY_STOP;
        ELSIF JammedSensor THEN
            state := STATE_JAM_DETECTED;
        ELSIF NOT MaterialInFeed THEN
            state := STATE_READY_TO_RUN;
        END_IF;
        MotorControl := TRUE;
        SafetyRelay := TRUE;

    ELSE
        state := STATE_INITIALIZE; (* Default to initialize state *)
END_CASE;

END_FUNCTION_BLOCK
END_ST