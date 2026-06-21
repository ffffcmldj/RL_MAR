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
    CurrentState : INT := 0; // 0: Idle, 1: Dough Preparation, 2: Topping Preparation, 3: Baking, 4: Cooling, 5: Stop
END_VAR

// Main control loop
IF StopButton THEN
    // Transition to Stop State
    DoughRollerMotor := FALSE;
    ToppingDispenser := FALSE;
    ConveyorMotor := FALSE;
    OvenHeater := FALSE;
    OvenTemperature := 0;
    CurrentState := 5; // Stop State
ELSE
    CASE CurrentState OF
        0: // Idle State
            IF StartButton THEN
                CurrentState := 1; // Transition to Dough Preparation State
            END_IF;

        1: // Dough Preparation State
            DoughRollerMotor := TRUE; // Activate Dough Roller Motor
            IF DoughReadySensor THEN
                DoughRollerMotor := FALSE; // Deactivate Dough Roller Motor
                CurrentState := 2; // Transition to Topping Preparation State
            END_IF;

        2: // Topping Preparation State
            ToppingDispenser := TRUE; // Activate Topping Dispenser
            IF ToppingsReadySensor THEN
                ToppingDispenser := FALSE; // Deactivate Topping Dispenser
                CurrentState := 3; // Transition to Baking State
            END_IF;

        3: // Baking State
            ConveyorMotor := TRUE; // Activate Conveyor Motor
            OvenHeater := TRUE; // Turn on Oven Heater
            OvenTemperature := 220; // Set Oven Temperature to 220°C
            IF BakingDoneSensor THEN
                ConveyorMotor := FALSE; // Deactivate Conveyor Motor
                OvenHeater := FALSE; // Turn off Oven Heater
                OvenTemperature := 0; // Set Oven Temperature to 0°C
                CurrentState := 4; // Transition to Cooling State
            END_IF;

        4: // Cooling State
            // Cooling process can be implemented here if needed
            // After cooling, transition back to Idle State
            CurrentState := 0; // Transition back to Idle State
    END_CASE;
END_IF;

END_FUNCTION_BLOCK