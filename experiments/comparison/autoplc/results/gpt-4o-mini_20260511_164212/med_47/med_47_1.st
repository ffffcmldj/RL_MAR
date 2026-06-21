FUNCTION_BLOCK WindowCleaningSystem
VAR_INPUT
    StartButton : BOOL;
    EmergencyStop : BOOL;
    UpperLimit : BOOL;
    LowerLimit : BOOL;
END_VAR

VAR_OUTPUT
    ElevatorUp : BOOL := FALSE;
    ElevatorDown : BOOL := FALSE;
    RotateClockwise : BOOL := FALSE;
    WaterPump : BOOL := FALSE;
END_VAR

VAR
    CleaningInProgress : BOOL := FALSE;
END_VAR

// Main control logic
IF EmergencyStop THEN
    // Emergency stop activated
    ElevatorUp := FALSE;
    ElevatorDown := FALSE;
    RotateClockwise := FALSE;
    WaterPump := FALSE;
    CleaningInProgress := FALSE;
ELSE
    IF NOT CleaningInProgress THEN
        // Idle State
        IF StartButton THEN
            // Start cleaning process
            CleaningInProgress := TRUE;
            ElevatorUp := TRUE; // Move elevator up
            ElevatorDown := FALSE; // Ensure elevator is not moving down
        END_IF
    ELSE
        // Cleaning Initiation State
        IF UpperLimit THEN
            // Upper limit reached
            ElevatorUp := FALSE; // Stop moving up
            RotateClockwise := TRUE; // Start cleaning
            WaterPump := TRUE; // Activate water pump
            ElevatorDown := TRUE; // Move elevator down
        END_IF
        
        // Cleaning State
        IF LowerLimit THEN
            // Lower limit reached
            RotateClockwise := FALSE; // Stop cleaning
            WaterPump := FALSE; // Deactivate water pump
            ElevatorDown := FALSE; // Stop moving down
            CleaningInProgress := FALSE; // Reset cleaning state
        END_IF
    END_IF
END_IF

END_FUNCTION_BLOCK