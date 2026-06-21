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

(* State Definitions *)
CONST
    STATE_IDLE := 0;
    STATE_ROLLING_DOUGH := 1;
    STATE_DISPENSING_TOPPINGS := 2;
    STATE_MOVING_TO_OVEN := 3;
    STATE_BAKING := 4;
    STATE_COOLING_OVEN := 5;
    STATE_EMERGENCY_STOP := 6;
END_CONST

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

(* Store previous state for debugging/tracking *)
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