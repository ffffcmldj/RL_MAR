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
    CurrentState : INT;  // 0=Idle, 1=Ascending, 2=Cleaning, 3=EmergencyStop
    PrevStartButton : BOOL;
    PrevEmergencyStop : BOOL;
END_VAR

// Initialize variables
CleaningInProgress := FALSE;
ElevatorUp := FALSE;
ElevatorDown := FALSE;
RotateClockwise := FALSE;
WaterPump := FALSE;
CurrentState := 0;
PrevStartButton := FALSE;
PrevEmergencyStop := FALSE;

// Main state machine logic
CASE CurrentState OF
    0: // Idle State
        // Check for rising edge on StartButton
        IF StartButton AND NOT PrevStartButton THEN
            IF NOT CleaningInProgress AND NOT EmergencyStop THEN
                CleaningInProgress := TRUE;
                CurrentState := 1; // Transition to Ascending state
            END_IF
        END_IF;
        
        // Ensure all outputs are off in Idle state
        ElevatorUp := FALSE;
        ElevatorDown := FALSE;
        RotateClockwise := FALSE;
        WaterPump := FALSE;
        
    1: // Ascending State
        // Check for EmergencyStop
        IF EmergencyStop THEN
            CurrentState := 3; // Transition to EmergencyStop state
            CleaningInProgress := FALSE;
            ElevatorUp := FALSE;
        ELSE
            // Activate elevator up movement
            ElevatorUp := TRUE;
            ElevatorDown := FALSE;
            RotateClockwise := FALSE;
            WaterPump := FALSE;
            
            // Check if upper limit reached
            IF UpperLimit THEN
                ElevatorUp := FALSE;
                CurrentState := 2; // Transition to Cleaning state
            END_IF
        END_IF;
        
    2: // Cleaning State
        // Check for EmergencyStop
        IF EmergencyStop THEN
            CurrentState := 3; // Transition to EmergencyStop state
            CleaningInProgress := FALSE;
            ElevatorDown := FALSE;
            RotateClockwise := FALSE;
            WaterPump := FALSE;
        ELSE
            // Activate cleaning operations
            ElevatorUp := FALSE;
            ElevatorDown := TRUE;
            RotateClockwise := TRUE;
            WaterPump := TRUE;
            
            // Check if lower limit reached
            IF LowerLimit THEN
                ElevatorDown := FALSE;
                RotateClockwise := FALSE;
                WaterPump := FALSE;
                CleaningInProgress := FALSE;
                CurrentState := 0; // Transition to Idle state
            END_IF
        END_IF;
        
    3: // EmergencyStop State
        // Deactivate all outputs
        ElevatorUp := FALSE;
        ElevatorDown := FALSE;
        RotateClockwise := FALSE;
        WaterPump := FALSE;
        CleaningInProgress := FALSE;
        
        // Check if EmergencyStop is released
        IF NOT EmergencyStop THEN
            CurrentState := 0; // Transition to Idle state
        END_IF;
        
END_CASE;

// Store previous values for edge detection
PrevStartButton := StartButton;
PrevEmergencyStop := EmergencyStop;

END_FUNCTION_BLOCK