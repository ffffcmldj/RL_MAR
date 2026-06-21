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
    State : INT := 0; (* 0=Idle, 1=DoughRolling, 2=ToppingDispensing, 3=ConveyingToOven, 4=Baking, 5=Complete *)
    TargetBakingTemp : INT := 220;
    IdleTemp : INT := 0;
END_VAR

(* Main state machine *)
CASE State OF
    0: (* Idle State *)
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := IdleTemp;
        
        IF StartButton AND NOT StopButton THEN
            State := 1;
        END_IF;
        
    1: (* Dough Rolling State *)
        IF StopButton THEN
            State := 0;
        ELSE
            DoughRollerMotor := NOT DoughReadySensor;
            ToppingDispenser := FALSE;
            ConveyorMotor := FALSE;
            OvenHeater := FALSE;
            OvenTemperature := IdleTemp;
            
            IF DoughReadySensor THEN
                State := 2;
            END_IF;
        END_IF;
        
    2: (* Topping Dispensing State *)
        IF StopButton THEN
            State := 0;
        ELSE
            DoughRollerMotor := FALSE;
            ToppingDispenser := NOT ToppingsReadySensor;
            ConveyorMotor := FALSE;
            OvenHeater := FALSE;
            OvenTemperature := IdleTemp;
            
            IF ToppingsReadySensor THEN
                State := 3;
            END_IF;
        END_IF;
        
    3: (* Convey to Oven State *)
        IF StopButton THEN
            State := 0;
        ELSE
            DoughRollerMotor := FALSE;
            ToppingDispenser := FALSE;
            ConveyorMotor := TRUE;
            OvenHeater := TRUE;
            OvenTemperature := TargetBakingTemp;
            
            (* Transition to baking state - in real implementation would use timer/sensor *)
            State := 4;
        END_IF;
        
    4: (* Baking State *)
        IF StopButton THEN
            State := 0;
        ELSE
            DoughRollerMotor := FALSE;
            ToppingDispenser := FALSE;
            ConveyorMotor := FALSE;
            OvenHeater := TRUE;
            OvenTemperature := TargetBakingTemp;
            
            IF BakingDoneSensor THEN
                State := 5;
            END_IF;
        END_IF;
        
    5: (* Baking Complete State *)
        IF StopButton THEN
            State := 0;
        ELSE
            DoughRollerMotor := FALSE;
            ToppingDispenser := FALSE;
            ConveyorMotor := FALSE;
            OvenHeater := FALSE;
            OvenTemperature := IdleTemp;
            
            (* Return to idle after completion *)
            State := 0;
        END_IF;
        
    ELSE
        (* Error state - reset to idle *)
        State := 0;
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := IdleTemp;
END_CASE;
END_FUNCTION_BLOCK