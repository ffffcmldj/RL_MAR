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
    SystemActive : BOOL;
    BakingActive : BOOL;
END_VAR

(* Emergency stop handling - highest priority *)
IF StopButton THEN
    SystemActive := FALSE;
    BakingActive := FALSE;
    DoughRollerMotor := FALSE;
    ToppingDispenser := FALSE;
    ConveyorMotor := FALSE;
    OvenHeater := FALSE;
    OvenTemperature := 0;
    RETURN;
END_IF;

(* System activation *)
IF StartButton AND NOT SystemActive THEN
    SystemActive := TRUE;
END_IF;

(* Main process logic - only active when system is running *)
IF SystemActive THEN
    (* Dough preparation phase *)
    IF NOT DoughReadySensor THEN
        DoughRollerMotor := TRUE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        BakingActive := FALSE;
    
    (* Topping application phase *)
    ELSIF DoughReadySensor AND NOT ToppingsReadySensor THEN
        DoughRollerMotor := FALSE;
        ToppingDispenser := TRUE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        BakingActive := FALSE;
    
    (* Baking phase - move to oven and bake *)
    ELSIF DoughReadySensor AND ToppingsReadySensor AND NOT BakingDoneSensor THEN
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        
        (* Conveyor runs until pizza is in oven, then oven heats *)
        IF NOT BakingActive THEN
            ConveyorMotor := TRUE;
            OvenHeater := FALSE;
            OvenTemperature := 0;
        ELSE
            ConveyorMotor := FALSE;
            OvenHeater := TRUE;
            OvenTemperature := 220;
        END_IF;
        
        (* Activate baking after conveyor has run *)
        BakingActive := TRUE;
    
    (* Baking complete - reset system *)
    ELSIF BakingDoneSensor AND BakingActive THEN
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        BakingActive := FALSE;
        SystemActive := FALSE;
    
    (* Default safe state *)
    ELSE
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        BakingActive := FALSE;
    END_IF;
ELSE
    (* System inactive - all outputs off *)
    DoughRollerMotor := FALSE;
    ToppingDispenser := FALSE;
    ConveyorMotor := FALSE;
    OvenHeater := FALSE;
    OvenTemperature := 0;
    BakingActive := FALSE;
END_IF;

END_FUNCTION_BLOCK;