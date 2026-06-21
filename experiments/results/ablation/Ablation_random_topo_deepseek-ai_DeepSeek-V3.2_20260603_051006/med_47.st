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
    SystemFault : BOOL;
END_VAR

VAR
    CleaningInProgress : BOOL;
    CurrentState : INT; // 0=IDLE, 1=ASCENDING, 2=CLEANING_DESCENDING
    AscendTimer : TON;
    DescendTimer : TON;
    StartButtonPrev : BOOL;
    AscendTimeout : TIME := T#30S; // Maximum allowed ascent time
    DescendTimeout : TIME := T#60S; // Maximum allowed descent time
END_VAR

// Emergency Stop - Highest Priority Safety Override
IF EmergencyStop THEN
    CleaningInProgress := FALSE;
    ElevatorUp := FALSE;
    ElevatorDown := FALSE;
    RotateClockwise := FALSE;
    WaterPump := FALSE;
    CurrentState := 0;
    AscendTimer(IN:=FALSE);
    DescendTimer(IN:=FALSE);
    SystemFault := FALSE;
    RETURN; // Exit function block immediately
END_IF;

// Detect rising edge of StartButton
IF StartButton AND NOT StartButtonPrev AND NOT CleaningInProgress THEN
    CleaningInProgress := TRUE;
    CurrentState := 1; // ASCENDING state
    AscendTimer(IN:=TRUE, PT:=AscendTimeout);
    DescendTimer(IN:=FALSE);
END_IF;
StartButtonPrev := StartButton;

// Main State Machine
IF CleaningInProgress THEN
    CASE CurrentState OF
        1: // ASCENDING state
            // Safety interlock: Ensure only one direction is active
            ElevatorUp := NOT UpperLimit AND NOT LowerLimit;
            ElevatorDown := FALSE;
            RotateClockwise := FALSE;
            WaterPump := FALSE;
            
            // Check for upper limit or timeout
            IF UpperLimit THEN
                CurrentState := 2; // Transition to CLEANING_DESCENDING
                AscendTimer(IN:=FALSE);
                DescendTimer(IN:=TRUE, PT:=DescendTimeout);
            ELSIF AscendTimer.Q THEN
                // Timeout detected - safety fault
                CleaningInProgress := FALSE;
                CurrentState := 0;
                SystemFault := TRUE;
                ElevatorUp := FALSE;
            END_IF;
            
        2: // CLEANING_DESCENDING state
            // Safety interlock: Ensure only one direction is active
            ElevatorUp := FALSE;
            ElevatorDown := NOT LowerLimit AND NOT UpperLimit;
            RotateClockwise := TRUE; // Brush activates during descent
            WaterPump := TRUE;       // Pump activates during descent
            
            // Check for lower limit or timeout
            IF LowerLimit THEN
                CleaningInProgress := FALSE;
                CurrentState := 0; // Return to IDLE
                DescendTimer(IN:=FALSE);
                ElevatorDown := FALSE;
                RotateClockwise := FALSE;
                WaterPump := FALSE;
            ELSIF DescendTimer.Q THEN
                // Timeout detected - safety fault
                CleaningInProgress := FALSE;
                CurrentState := 0;
                SystemFault := TRUE;
                ElevatorDown := FALSE;
                RotateClockwise := FALSE;
                WaterPump := FALSE;
            END_IF;
    END_CASE;
ELSE
    // IDLE state - ensure all outputs are off
    ElevatorUp := FALSE;
    ElevatorDown := FALSE;
    RotateClockwise := FALSE;
    WaterPump := FALSE;
    CurrentState := 0;
    AscendTimer(IN:=FALSE);
    DescendTimer(IN:=FALSE);
    
    // Auto-reset fault if system is manually restarted
    IF StartButton AND NOT StartButtonPrev THEN
        SystemFault := FALSE;
    END_IF;
END_IF;

// Final safety interlock to prevent simultaneous up/down movement
// This is a redundant safety check
IF ElevatorUp AND ElevatorDown THEN
    ElevatorUp := FALSE;
    ElevatorDown := FALSE;
    SystemFault := TRUE;
END_IF;

END_FUNCTION_BLOCK