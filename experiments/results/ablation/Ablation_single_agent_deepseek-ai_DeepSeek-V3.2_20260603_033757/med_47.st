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
    AtUpperLimitFlag : BOOL;
    DescendingPhase : BOOL;
END_VAR

(* Safety and State Management Logic *)
IF EmergencyStop THEN
    CleaningInProgress := FALSE;
    AtUpperLimitFlag := FALSE;
    DescendingPhase := FALSE;
END_IF;

(* Main Process Sequencing *)
IF NOT EmergencyStop THEN
    (* Start Command Latching *)
    IF StartButton AND NOT CleaningInProgress AND NOT LowerLimit THEN
        CleaningInProgress := TRUE;
        AtUpperLimitFlag := FALSE;
        DescendingPhase := FALSE;
    END_IF;

    (* State: Moving Up to Upper Limit *)
    IF CleaningInProgress AND NOT AtUpperLimitFlag AND NOT DescendingPhase THEN
        IF NOT UpperLimit THEN
            ElevatorUp := TRUE;
            ElevatorDown := FALSE;
            RotateClockwise := FALSE;
            WaterPump := FALSE;
        ELSE
            (* Reached Upper Limit *)
            ElevatorUp := FALSE;
            AtUpperLimitFlag := TRUE;
            DescendingPhase := TRUE;
        END_IF;
    END_IF;

    (* State: Descending and Cleaning *)
    IF CleaningInProgress AND DescendingPhase THEN
        IF NOT LowerLimit THEN
            ElevatorUp := FALSE;
            ElevatorDown := TRUE;
            RotateClockwise := TRUE;
            WaterPump := TRUE;
        ELSE
            (* Reached Lower Limit - Process Complete *)
            ElevatorDown := FALSE;
            RotateClockwise := FALSE;
            WaterPump := FALSE;
            CleaningInProgress := FALSE;
            AtUpperLimitFlag := FALSE;
            DescendingPhase := FALSE;
        END_IF;
    END_IF;

    (* Idle State Outputs *)
    IF NOT CleaningInProgress THEN
        ElevatorUp := FALSE;
        ElevatorDown := FALSE;
        RotateClockwise := FALSE;
        WaterPump := FALSE;
    END_IF;
ELSE
    (* Emergency Stop Active - Force all outputs FALSE *)
    ElevatorUp := FALSE;
    ElevatorDown := FALSE;
    RotateClockwise := FALSE;
    WaterPump := FALSE;
END_IF;

END_FUNCTION_BLOCK