FUNCTION_BLOCK ShredderControl
VAR_INPUT
    StartButton : BOOL;
    StopButton : BOOL;
    EmergencyStop : BOOL;
    MotorStatus : BOOL;
    MaterialInFeed : BOOL;
    JammedSensor : BOOL;
END_VAR
VAR_OUTPUT
    MotorControl : BOOL;
    SafetyRelay : BOOL;
END_VAR
VAR
    bSafetyActive : BOOL;
    bStartTrigger : BOOL;
    bStopTrigger : BOOL;
END_VAR

MotorControl := FALSE;
SafetyRelay := FALSE;

bSafetyActive := NOT EmergencyStop AND NOT JammedSensor;

IF EmergencyStop THEN
    SafetyRelay := FALSE;
    MotorControl := FALSE;
ELSIF JammedSensor THEN
    SafetyRelay := FALSE;
    MotorControl := FALSE;
ELSE
    SafetyRelay := TRUE;
    bStartTrigger := StartButton OR MaterialInFeed;
    bStopTrigger := StopButton;

    IF bStopTrigger THEN
        MotorControl := FALSE;
    ELSIF bStartTrigger THEN
        MotorControl := TRUE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK