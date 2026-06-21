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

    (* Initialize outputs *)
    MotorControl := FALSE;
    SafetyRelay := FALSE;

    (* Main control logic *)
    IF EmergencyStop OR JammedSensor THEN
        (* Emergency Stop or Jam detected *)
        MotorControl := FALSE; (* Stop the motor *)
        SafetyRelay := FALSE; (* Deactivate safety relay *)
    ELSE
        (* Normal operation handling *)
        IF StartButton AND MaterialInFeed THEN
            MotorControl := TRUE; (* Start the motor *)
            SafetyRelay := TRUE; (* Activate safety relay *)
        ELSIF StopButton OR NOT MaterialInFeed THEN
            MotorControl := FALSE; (* Stop the motor *)
            SafetyRelay := FALSE; (* Deactivate safety relay *)
        END_IF
    END_IF
END_FUNCTION_BLOCK