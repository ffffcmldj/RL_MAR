FUNCTION_BLOCK ShredderControl
    VAR_INPUT
        StartButton : BOOL;
        StopButton : BOOL;
        EmergencyStop : BOOL;
        MaterialInFeed : BOOL;
        JammedSensor : BOOL;
    END_VAR

    VAR_OUTPUT
        MotorControl : BOOL;
        SafetyRelay : BOOL;
    END_VAR

    VAR
        bMotorRunning : BOOL;
    END_VAR

    (* Highest Priority: Emergency Stop and Jam Detection *)
    IF EmergencyStop OR JammedSensor THEN
        MotorControl := FALSE;
        SafetyRelay := FALSE;
        bMotorRunning := FALSE;
    ELSE
        (* Normal Operation Logic *)
        IF (StartButton OR MaterialInFeed) AND NOT bMotorRunning THEN
            bMotorRunning := TRUE;
        ELSIF StopButton THEN
            bMotorRunning := FALSE;
        END_IF;

        (* Motor Control Output *)
        MotorControl := bMotorRunning;

        (* Safety Relay Output - Active during normal operation when motor is running or ready to run *)
        SafetyRelay := bMotorRunning OR ((StartButton OR MaterialInFeed) AND NOT StopButton);
    END_IF;

END_FUNCTION_BLOCK;