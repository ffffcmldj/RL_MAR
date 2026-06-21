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
    StartRisingEdge : BOOL;
    PrevStartButton : BOOL;
    AtUpperLimit : BOOL;
    AtLowerLimit : BOOL;
    ElevatorMoving : BOOL;
END_VAR

    // Detect rising edge of StartButton
    StartRisingEdge := StartButton AND NOT PrevStartButton;
    PrevStartButton := StartButton;

    // Emergency Stop has highest priority
    IF EmergencyStop THEN
        CleaningInProgress := FALSE;
        ElevatorMoving := FALSE;
        AtUpperLimit := FALSE;
        AtLowerLimit := FALSE;
        ElevatorUp := FALSE;
        ElevatorDown := FALSE;
        RotateClockwise := FALSE;
        WaterPump := FALSE;
    ELSE
        // Start cleaning cycle on rising edge when not already in progress
        IF StartRisingEdge AND NOT CleaningInProgress THEN
            CleaningInProgress := TRUE;
            ElevatorMoving := TRUE;
            AtUpperLimit := FALSE;
            AtLowerLimit := FALSE;
        END_IF;

        // Main cleaning cycle logic
        IF CleaningInProgress THEN
            // Detect when upper limit is reached during upward movement
            IF NOT AtUpperLimit AND UpperLimit AND ElevatorUp THEN
                AtUpperLimit := TRUE;
                ElevatorMoving := FALSE;
            END_IF;

            // Control elevator movement direction
            IF NOT AtUpperLimit AND ElevatorMoving THEN
                // Moving up phase
                ElevatorUp := TRUE;
                ElevatorDown := FALSE;
            ELSIF AtUpperLimit AND NOT AtLowerLimit THEN
                // Moving down phase
                ElevatorUp := FALSE;
                ElevatorDown := TRUE;
                ElevatorMoving := TRUE;
            END_IF;

            // Activate cleaning tools when at upper limit and moving down
            IF AtUpperLimit AND NOT AtLowerLimit THEN
                RotateClockwise := TRUE;
                WaterPump := TRUE;
            ELSE
                RotateClockwise := FALSE;
                WaterPump := FALSE;
            END_IF;

            // Detect when lower limit is reached
            IF LowerLimit AND ElevatorDown THEN
                AtLowerLimit := TRUE;
                ElevatorDown := FALSE;
                ElevatorMoving := FALSE;
                CleaningInProgress := FALSE;
                RotateClockwise := FALSE;
                WaterPump := FALSE;
            END_IF;
        ELSE
            // Idle state - all outputs off
            ElevatorUp := FALSE;
            ElevatorDown := FALSE;
            RotateClockwise := FALSE;
            WaterPump := FALSE;
            ElevatorMoving := FALSE;
        END_IF;
    END_IF;
END_FUNCTION_BLOCK