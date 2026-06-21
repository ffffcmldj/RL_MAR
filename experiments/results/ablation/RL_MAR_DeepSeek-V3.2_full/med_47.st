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
        StartButtonPrev : BOOL;
        StartRisingEdge : BOOL;
    END_VAR

    (* Emergency Stop has highest priority - force safe state *)
    IF EmergencyStop THEN
        CleaningInProgress := FALSE;
        ElevatorUp := FALSE;
        ElevatorDown := FALSE;
        RotateClockwise := FALSE;
        WaterPump := FALSE;
        StartButtonPrev := FALSE;
    ELSE
        (* Detect rising edge of StartButton *)
        StartRisingEdge := StartButton AND NOT StartButtonPrev;
        StartButtonPrev := StartButton;

        (* Start sequence only on rising edge when idle and at lower limit *)
        IF NOT CleaningInProgress AND StartRisingEdge AND LowerLimit THEN
            CleaningInProgress := TRUE;
        END_IF;

        (* Main operational logic *)
        IF CleaningInProgress THEN
            (* Ascent phase: move up until upper limit is reached *)
            IF NOT UpperLimit THEN
                ElevatorUp := TRUE;
                ElevatorDown := FALSE;
                RotateClockwise := FALSE;
                WaterPump := FALSE;
            (* Descent and cleaning phase: move down with tools active until lower limit *)
            ELSE
                ElevatorUp := FALSE;
                ElevatorDown := TRUE;
                RotateClockwise := TRUE;
                WaterPump := TRUE;
            END_IF;

            (* End of cycle: reached lower limit *)
            IF LowerLimit THEN
                CleaningInProgress := FALSE;
                ElevatorDown := FALSE;
                RotateClockwise := FALSE;
                WaterPump := FALSE;
            END_IF;
        ELSE
            (* Idle state: all outputs off *)
            ElevatorUp := FALSE;
            ElevatorDown := FALSE;
            RotateClockwise := FALSE;
            WaterPump := FALSE;
        END_IF;
    END_IF;
END_FUNCTION_BLOCK;