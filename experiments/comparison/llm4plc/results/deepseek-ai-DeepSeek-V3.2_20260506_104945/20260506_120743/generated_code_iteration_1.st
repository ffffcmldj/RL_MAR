START_REASON
The feedback indicates a CODESYS compiler validation error: "应该用';' 替换'STATE_IDLE'". This is a Chinese error message meaning "should replace 'STATE_IDLE' with ';'". In CODESYS Structured Text, the CONST section requires each constant assignment to end with a semicolon (;), not a colon-equals (:=) followed by a semicolon. The current code uses "STATE_IDLE := 0;" which is incorrect for CODESYS. In CODESYS, constants are defined with "STATE_IDLE : INT := 0;" (with a colon, not colon-equals). However, the error message suggests replacing 'STATE_IDLE' with ';', which might be a misinterpretation—likely, the issue is the syntax of the constant definition. In CODESYS ST, the correct syntax for constants within a FUNCTION_BLOCK is to declare them in the VAR_CONSTANT section with proper type and assignment using ":=". The current code uses "CONST ... END_CONST" with ":=" which is not standard CODESYS. I need to change the constant definitions to use VAR_CONSTANT with proper syntax. Also, ensure all variable sections are closed with END_VAR, not END_VAR_INPUT or END_VAR_OUTPUT, which is already correct in the code. I'll adjust the constant definitions to comply with CODESYS standards.
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

VAR_CONSTANT
    STATE_IDLE : INT := 0;
    STATE_ROLLING_DOUGH : INT := 1;
    STATE_DISPENSING_TOPPINGS : INT := 2;
    STATE_MOVING_TO_OVEN : INT := 3;
    STATE_BAKING : INT := 4;
    STATE_COOLING_OVEN : INT := 5;
    STATE_EMERGENCY_STOP : INT := 6;
END_VAR

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