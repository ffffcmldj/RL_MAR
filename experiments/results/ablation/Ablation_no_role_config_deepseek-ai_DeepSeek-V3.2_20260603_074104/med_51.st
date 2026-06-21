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
    State : INT;
    OvenTargetTemp : INT;
END_VAR

// State definitions
CONSTANT
    STATE_IDLE : INT := 0;
    STATE_ROLLING_DOUGH : INT := 1;
    STATE_ADDING_TOPPINGS : INT := 2;
    STATE_MOVING_TO_OVEN : INT := 3;
    STATE_BAKING : INT := 4;
    STATE_COMPLETE : INT := 5;
END_CONSTANT

// Main state machine logic
IF StopButton THEN
    // Emergency stop - reset everything
    State := STATE_IDLE;
    DoughRollerMotor := FALSE;
    ToppingDispenser := FALSE;
    ConveyorMotor := FALSE;
    OvenHeater := FALSE;
    OvenTargetTemp := 0;
ELSE
    CASE State OF
        STATE_IDLE:
            DoughRollerMotor := FALSE;
            ToppingDispenser := FALSE;
            ConveyorMotor := FALSE;
            OvenHeater := FALSE;
            OvenTargetTemp := 0;
            
            IF StartButton THEN
                State := STATE_ROLLING_DOUGH;
            END_IF;
            
        STATE_ROLLING_DOUGH:
            DoughRollerMotor := TRUE;
            ToppingDispenser := FALSE;
            ConveyorMotor := FALSE;
            OvenHeater := FALSE;
            OvenTargetTemp := 0;
            
            IF DoughReadySensor THEN
                State := STATE_ADDING_TOPPINGS;
            END_IF;
            
        STATE_ADDING_TOPPINGS:
            DoughRollerMotor := FALSE;
            ToppingDispenser := TRUE;
            ConveyorMotor := FALSE;
            OvenHeater := FALSE;
            OvenTargetTemp := 0;
            
            IF ToppingsReadySensor THEN
                State := STATE_MOVING_TO_OVEN;
            END_IF;
            
        STATE_MOVING_TO_OVEN:
            DoughRollerMotor := FALSE;
            ToppingDispenser := FALSE;
            ConveyorMotor := TRUE;
            OvenHeater := TRUE; // Start heating oven
            OvenTargetTemp := 220;
            
            // Assume conveyor moves pizza to oven automatically
            // In real system, would have position sensor
            State := STATE_BAKING;
            
        STATE_BAKING:
            DoughRollerMotor := FALSE;
            ToppingDispenser := FALSE;
            ConveyorMotor := FALSE;
            OvenHeater := TRUE;
            OvenTargetTemp := 220;
            
            IF BakingDoneSensor THEN
                State := STATE_COMPLETE;
            END_IF;
            
        STATE_COMPLETE:
            DoughRollerMotor := FALSE;
            ToppingDispenser := FALSE;
            ConveyorMotor := FALSE;
            OvenHeater := FALSE;
            OvenTargetTemp := 0;
            
            // Wait for next start command
            IF NOT StartButton THEN
                State := STATE_IDLE;
            END_IF;
            
    END_CASE;
END_IF;

// Set oven temperature output
OvenTemperature := OvenTargetTemp;

END_FUNCTION_BLOCK