plaintext
START_ST
FUNCTION_BLOCK WindowCleaningSystem
VAR_INPUT
    StartButton : BOOL; // Input to start the cleaning process
    EmergencyStop : BOOL; // Input to trigger the emergency stop
    UpperLimit : BOOL; // Input to indicate the elevator has reached the upper limit
    LowerLimit : BOOL; // Input to indicate the elevator has reached the lower limit
END_VAR

VAR_OUTPUT
    ElevatorUp : BOOL; // Output to move the elevator upward
    ElevatorDown : BOOL; // Output to move the elevator downward
    RotateClockwise : BOOL; // Output to activate the cleaning brush
    WaterPump : BOOL; // Output to activate the water pump
END_VAR

VAR
    state : INT; // The current state of the system
    prevState : INT; // The previous state of the system
    CleaningInProgress : BOOL; // Flag to indicate if cleaning is in progress
END_VAR

// State Definitions
// STATE 0: IDLE
// STATE 1: MOVING_UP
// STATE 2: CLEANING
// STATE 3: EMERGENCY_STOP

// Initialization
IF NOT CleaningInProgress THEN
    state := 0; // Default to IDLE state
END_IF

// State Machine Logic
CASE state OF
    // STATE 0: IDLE
    0: 
        ElevatorUp := FALSE;
        ElevatorDown := FALSE;
        RotateClockwise := FALSE;
        WaterPump := FALSE;
        CleaningInProgress := FALSE;

        // Transition to MOVING_UP if StartButton is pressed and no EmergencyStop
        IF StartButton AND NOT CleaningInProgress AND NOT EmergencyStop THEN
            state := 1;
            CleaningInProgress := TRUE;
        END_IF;

    // STATE 1: MOVING_UP
    1: 
        ElevatorUp := TRUE;
        ElevatorDown := FALSE;
        RotateClockwise := FALSE;
        WaterPump := FALSE;

        // Transition to CLEANING if UpperLimit is reached
        IF UpperLimit AND NOT EmergencyStop THEN
            state := 2;
        END_IF;

    // STATE 2: CLEANING
    2: 
        ElevatorUp := FALSE;
        ElevatorDown := TRUE;
        RotateClockwise := TRUE;
        WaterPump := TRUE;

        // Transition to IDLE if LowerLimit is reached
        IF LowerLimit AND NOT EmergencyStop THEN
            state := 0;
        END_IF;

    // STATE 3: EMERGENCY_STOP
    3: 
        ElevatorUp := FALSE;
        ElevatorDown := FALSE;
        RotateClockwise := FALSE;
        WaterPump := FALSE;

        // Remain in EMERGENCY_STOP until EmergencyStop is deactivated
        IF NOT EmergencyStop THEN
            state := prevState; // Return to the previous state
        END_IF;

    ELSE
        // Default case to handle unexpected states
        state := 0; // Reset to IDLE
END_CASE;

// Emergency Stop Logic
IF EmergencyStop THEN
    prevState := state; // Save the current state
    state := 3; // Transition to EMERGENCY_STOP
END_IF;

END_FUNCTION_BLOCK
END_ST