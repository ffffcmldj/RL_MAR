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
    CurrentState : INT := 0;
    NextState : INT := 0;
END_VAR

(* State Machine Execution *)
CurrentState := NextState;

CASE CurrentState OF
    0: (* IDLE STATE *)
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        
        IF StartButton AND NOT StopButton THEN
            NextState := 1;
        ELSE
            NextState := 0;
        END_IF;
        
    1: (* PREPARE_DOUGH STATE *)
        DoughRollerMotor := TRUE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        
        IF StopButton THEN
            NextState := 0;
        ELSIF DoughReadySensor THEN
            NextState := 2;
        ELSE
            NextState := 1;
        END_IF;
        
    2: (* ADD_TOPPINGS STATE *)
        DoughRollerMotor := FALSE;
        ToppingDispenser := TRUE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        
        IF StopButton THEN
            NextState := 0;
        ELSIF ToppingsReadySensor THEN
            NextState := 3;
        ELSE
            NextState := 2;
        END_IF;
        
    3: (* MOVE_TO_OVEN STATE *)
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := TRUE;
        OvenHeater := TRUE;
        OvenTemperature := 220;
        
        IF StopButton THEN
            NextState := 0;
        ELSIF BakingDoneSensor THEN
            NextState := 4;
        ELSE
            NextState := 3;
        END_IF;
        
    4: (* BAKING_COMPLETE STATE *)
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        
        IF StopButton OR NOT StartButton THEN
            NextState := 0;
        ELSE
            NextState := 4;
        END_IF;
        
    ELSE
        (* Error handling: Reset to IDLE state *)
        NextState := 0;
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        
END_CASE;

END_FUNCTION_BLOCK