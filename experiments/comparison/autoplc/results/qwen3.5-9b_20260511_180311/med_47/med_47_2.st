FUNCTION_BLOCK WindowCleaningSystem
VAR_INPUT
    StartButton : BOOL;
    EmergencyStop : BOOL;
    UpperLimit : BOOL;
    LowerLimit : BOOL;
END_VAR
VAR_OUTPUT
    ElevatorUp : BOOL;
    ElevatorDown : BOOL;
    RotateClockwise : BOOL;
    WaterPump : BOOL;
END_VAR
VAR
    CleaningInProgress : BOOL;
END_VAR

(* Initialization logic moved to the execution body *)
CleaningInProgress := FALSE;

IF EmergencyStop THEN
    ElevatorUp := FALSE;
    ElevatorDown := FALSE;
    RotateClockwise := FALSE;
    WaterPump := FALSE;
    CleaningInProgress := FALSE;
ELSIF NOT CleaningInProgress THEN
    IF StartButton THEN
        ElevatorUp := TRUE;
        ElevatorDown := FALSE;
        RotateClockwise := FALSE;
        WaterPump := FALSE;
        CleaningInProgress := TRUE;
    ELSE
        ElevatorUp := FALSE;
        ElevatorDown := FALSE;
        RotateClockwise := FALSE;
        WaterPump := FALSE;
    END_IF;
ELSE
    IF UpperLimit THEN
        ElevatorUp := FALSE;
        ElevatorDown := FALSE;
        RotateClockwise := TRUE;
        WaterPump := TRUE;
    ELSIF NOT LowerLimit THEN
        ElevatorUp := FALSE;
        ElevatorDown := TRUE;
        RotateClockwise := TRUE;
        WaterPump := TRUE;
    ELSE
        ElevatorUp := FALSE;
        ElevatorDown := FALSE;
        RotateClockwise := FALSE;
        WaterPump := FALSE;
        CleaningInProgress := FALSE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK