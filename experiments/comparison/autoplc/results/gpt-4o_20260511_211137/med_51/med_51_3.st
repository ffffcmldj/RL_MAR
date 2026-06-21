FUNCTION_BLOCK PizzaMakingMachine
VAR_INPUT
    StartButton : BOOL;
    StopButton : BOOL;
    DoughReadySensor : BOOL;
    ToppingsReadySensor : BOOL;
    BakingDoneSensor : BOOL;
END_VAR

VAR_OUTPUT
    DoughRollerMotor : BOOL := FALSE;
    ToppingDispenser : BOOL := FALSE;
    ConveyorMotor : BOOL := FALSE;
    OvenHeater : BOOL := FALSE;
    OvenTemperature : INT := 0;
END_VAR

VAR
    CurrentState : INT := 0; // 0: Idle, 1: Dough Preparation, 2: Topping Preparation, 3: Pizza Transfer, 4: Baking, 5: Completion
END_VAR

// State Definitions
CONST
    STATE_IDLE : INT := 0;
    STATE_DOUGH_PREPARATION : INT := 1;
    STATE_TOPPING_PREPARATION : INT := 2;
    STATE_PIZZA_TRANSFER : INT := 3;
    STATE_BAKING : INT := 4;
    STATE_COMPLETION : INT := 5;
END_CONST

// Main Control Logic
IF StopButton THEN
    // Transition to Idle State
    CurrentState := STATE_IDLE;
    DoughRollerMotor := FALSE;
    ToppingDispenser := FALSE;
    ConveyorMotor := FALSE;
    OvenHeater := FALSE;
    OvenTemperature := 0;
ELSE
    CASE CurrentState OF
        STATE_IDLE:
            IF StartButton THEN
                CurrentState := STATE_DOUGH_PREPARATION;
            END_IF;

        STATE_DOUGH_PREPARATION:
            DoughRollerMotor := TRUE;
            IF DoughReadySensor THEN
                DoughRollerMotor := FALSE;
                CurrentState := STATE_TOPPING_PREPARATION;
            END_IF;

        STATE_TOPPING_PREPARATION:
            ToppingDispenser := TRUE;
            IF ToppingsReadySensor THEN
                ToppingDispenser := FALSE;
                CurrentState := STATE_PIZZA_TRANSFER;
            END_IF;

        STATE_PIZZA_TRANSFER:
            ConveyorMotor := TRUE;
            // Assuming a condition or delay to simulate pizza transfer completion
            ConveyorMotor := FALSE;
            CurrentState := STATE_BAKING;

        STATE_BAKING:
            OvenHeater := TRUE;
            OvenTemperature := 220;
            IF BakingDoneSensor THEN
                OvenHeater := FALSE;
                OvenTemperature := 0;
                CurrentState := STATE_COMPLETION;
            END_IF;

        STATE_COMPLETION:
            // Ensure all operations are stopped
            DoughRollerMotor := FALSE;
            ToppingDispenser := FALSE;
            ConveyorMotor := FALSE;
            OvenHeater := FALSE;
            OvenTemperature := 0;
            CurrentState := STATE_IDLE;
    END_CASE;
END_IF;
END_FUNCTION_BLOCK