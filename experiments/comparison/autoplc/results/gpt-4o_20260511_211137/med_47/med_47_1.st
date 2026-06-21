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
    CleaningInProgress : BOOL := FALSE;
END_VAR

VAR
    CurrentState : INT := 0; // 0: Idle, 1: Ascending, 2: Cleaning, 3: Descending, 4: Emergency Stop
END_VAR

VAR CONSTANT
    STATE_IDLE : INT := 0;
    STATE_ASCENDING : INT := 1;
    STATE_CLEANING : INT := 2;
    STATE_DESCENDING : INT := 3;
    STATE_EMERGENCY_STOP : INT := 4;
END_VAR

// Main logic
IF EmergencyStop THEN
    // Emergency Stop Logic
    ElevatorUp := FALSE;
    ElevatorDown := FALSE;
    RotateClockwise := FALSE;
    WaterPump := FALSE;
    CleaningInProgress := FALSE;
    CurrentState := STATE_EMERGENCY_STOP;
ELSE
    CASE CurrentState OF
        STATE_IDLE:
            // Idle State Logic
            IF StartButton AND NOT CleaningInProgress THEN
                ElevatorUp := TRUE;
                CleaningInProgress := TRUE;
                CurrentState := STATE_ASCENDING;
            END_IF

        STATE_ASCENDING:
            // Ascending State Logic
            IF UpperLimit THEN
                ElevatorUp := FALSE;
                RotateClockwise := TRUE;
                WaterPump := TRUE;
                CurrentState := STATE_CLEANING;
            END_IF

        STATE_CLEANING:
            // Cleaning State Logic
            ElevatorDown := TRUE;
            IF LowerLimit THEN
                ElevatorDown := FALSE;
                RotateClockwise := FALSE;
                WaterPump := FALSE;
                CleaningInProgress := FALSE;
                CurrentState := STATE_IDLE;
            END_IF

        STATE_DESCENDING:
            // Descending State Logic
            IF LowerLimit THEN
                ElevatorDown := FALSE;
                RotateClockwise := FALSE;
                WaterPump := FALSE;
                CleaningInProgress := FALSE;
                CurrentState := STATE_IDLE;
            END_IF

        STATE_EMERGENCY_STOP:
            // Remain in Emergency Stop State until cleared
            IF NOT EmergencyStop THEN
                CurrentState := STATE_IDLE;
            END_IF
    END_CASE
END_IF
END_FUNCTION_BLOCK