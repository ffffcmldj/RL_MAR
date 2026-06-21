plaintext
START_ST
FUNCTION_BLOCK PizzaMakingMachine
VAR_INPUT
    StartButton : BOOL;
    StopButton : BOOL;
    DoughReadySensor : BOOL;
    ToppingsReadySensor : BOOL;
    BakingDoneSensor : BOOL;
END_VAR

VAR_OUTPUT
    DoughRollerMotor : BOOL;
    ToppingDispenser : BOOL;
    ConveyorMotor : BOOL;
    OvenHeater : BOOL;
    OvenTemperature : INT;
END_VAR

VAR
    state : INT := 0; // Current state of the FSM
    prevState : INT := 0; // Previous state of the FSM
    conveyorTimer : TIME := T#0S; // Timer for conveyor operation
    coolingTimer : TIME := T#0S; // Timer for cooling operation
    conveyorTimerActive : BOOL := FALSE; // Indicates if conveyor timer is active
    coolingTimerActive : BOOL := FALSE; // Indicates if cooling timer is active
END_VAR

// Main logic
IF StopButton THEN
    // Immediate transition to IDLE state
    state := 0;
END_IF

CASE state OF
    0: // STATE 0: IDLE
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;

        IF StartButton AND NOT StopButton THEN
            state := 1; // Transition to STATE 1: DOUGH PREPARATION
        END_IF

    1: // STATE 1: DOUGH PREPARATION
        DoughRollerMotor := TRUE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;

        IF DoughReadySensor THEN
            state := 2; // Transition to STATE 2: TOPPING DISPENSING
        END_IF

    2: // STATE 2: TOPPING DISPENSING
        DoughRollerMotor := FALSE;
        ToppingDispenser := TRUE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;

        IF ToppingsReadySensor THEN
            state := 3; // Transition to STATE 3: CONVEYING TO OVEN
            conveyorTimer := T#5S; // Set conveyor operation duration
            conveyorTimerActive := TRUE;
        END_IF

    3: // STATE 3: CONVEYING TO OVEN
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := TRUE;
        OvenHeater := FALSE;
        OvenTemperature := 0;

        IF conveyorTimerActive THEN
            conveyorTimer := conveyorTimer - T#1S;
            IF conveyorTimer <= T#0S THEN
                conveyorTimerActive := FALSE;
                state := 4; // Transition to STATE 4: BAKING
            END_IF
        END_IF

    4: // STATE 4: BAKING
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := TRUE;
        OvenTemperature := 220;

        IF BakingDoneSensor THEN
            state := 5; // Transition to STATE 5: COOLING DOWN
            coolingTimer := T#5S; // Set cooling duration
            coolingTimerActive := TRUE;
        END_IF

    5: // STATE 5: COOLING DOWN
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;

        IF coolingTimerActive THEN
            coolingTimer := coolingTimer - T#1S;
            IF coolingTimer <= T#0S THEN
                coolingTimerActive := FALSE;
                state := 0; // Transition back to STATE 0: IDLE
            END_IF
        END_IF

ELSE
    // Default case to handle unexpected states
    state := 0; // Reset to IDLE state
END_CASE
END_FUNCTION_BLOCK
END_ST