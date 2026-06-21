START_REASON
The feedback indicates that the CODESYS compiler validation failed because VAR_CONSTANT is not allowed in the current context. In CODESYS Structured Text, constants should be defined using the CONSTANT keyword directly, not within a VAR_CONSTANT section. The error message "应该采用VAR, VAR_INPUT, VAR_OUTPUT 或 VAR_IN_OUT 取代VAR_CONSTANT" suggests replacing VAR_CONSTANT with one of the standard variable sections. To fix this, I need to change the constant definitions to use the correct syntax: either define them as global constants outside the FUNCTION_BLOCK or use proper constant declarations within the block. Since the constants are specific to this function block, I'll define them as local constants using the correct CODESYS syntax. In CODESYS, constants in a function block are typically declared with "CONSTANT" without the VAR prefix. I'll adjust the code accordingly to comply with CODESYS standards.
END_REASON

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
    state : INT;
    prevState : INT;
    internalStopFlag : BOOL;
END_VAR

CONSTANT
    STATE_IDLE : INT := 0;
    STATE_ROLLING_DOUGH : INT := 1;
    STATE_DISPENSING_TOPPINGS : INT := 2;
    STATE_MOVING_TO_OVEN : INT := 3;
    STATE_BAKING : INT := 4;
    STATE_COOLING_OVEN : INT := 5;
    STATE_EMERGENCY_STOP : INT := 6;
END_CONSTANT

(* Main Logic *)
IF StopButton THEN
    state := STATE_EMERGENCY_STOP;
    internalStopFlag := TRUE;
ELSIF internalStopFlag AND NOT StartButton THEN
    state := STATE_IDLE;
    internalStopFlag := FALSE;
ELSE
    CASE state OF
        STATE_IDLE:
            IF StartButton AND NOT StopButton THEN
                state := STATE_ROLLING_DOUGH;
            END_IF;

        STATE_ROLLING_DOUGH:
            IF DoughReadySensor THEN
                state := STATE_DISPENSING_TOPPINGS;
            END_IF;

        STATE_DISPENSING_TOPPINGS:
            IF ToppingsReadySensor THEN
                state := STATE_MOVING_TO_OVEN;
            END_IF;

        STATE_MOVING_TO_OVEN:
            IF NOT BakingDoneSensor THEN
                state := STATE_BAKING;
            END_IF;

        STATE_BAKING:
            IF BakingDoneSensor THEN
                state := STATE_COOLING_OVEN;
            END_IF;

        STATE_COOLING_OVEN:
            state := STATE_IDLE;

        STATE_EMERGENCY_STOP:
            (* Stay in emergency stop until conditions handled above *)
    END_CASE;
END_IF;

(* Store previous state for debugging *)
prevState := state;

(* Set outputs based on current state *)
CASE state OF
    STATE_IDLE:
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;

    STATE_ROLLING_DOUGH:
        DoughRollerMotor := TRUE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;

    STATE_DISPENSING_TOPPINGS:
        DoughRollerMotor := FALSE;
        ToppingDispenser := TRUE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;

    STATE_MOVING_TO_OVEN:
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := TRUE;
        OvenHeater := FALSE;
        OvenTemperature := 0;

    STATE_BAKING:
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := TRUE;
        OvenTemperature := 220;

    STATE_COOLING_OVEN:
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;

    STATE_EMERGENCY_STOP:
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
END_CASE;

END_FUNCTION_BLOCK
END_ST