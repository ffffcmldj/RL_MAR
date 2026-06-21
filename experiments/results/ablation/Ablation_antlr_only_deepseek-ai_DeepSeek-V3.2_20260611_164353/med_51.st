TYPE
    PizzaState : (
        Idle,
        DoughRolling,
        ToppingDispensing,
        ConveyingToOven,
        Baking,
        Cooling,
        Complete
    );
END_TYPE

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
    State : PizzaState;
    SystemActive : BOOL;
    ConveyorTimer : TON;
    BakingTimer : TON;
    CoolingTimer : TON;
    ConveyorTimePreset : TIME := T#5S;
    BakingTimePreset : TIME := T#30S;
    CoolingTimePreset : TIME := T#10S;
END_VAR

(* Emergency Stop Handling *)
IF StopButton THEN
    SystemActive := FALSE;
    State := PizzaState.Idle;
    DoughRollerMotor := FALSE;
    ToppingDispenser := FALSE;
    ConveyorMotor := FALSE;
    OvenHeater := FALSE;
    OvenTemperature := 0;
    ConveyorTimer(IN := FALSE, PT := ConveyorTimePreset);
    BakingTimer(IN := FALSE, PT := BakingTimePreset);
    CoolingTimer(IN := FALSE, PT := CoolingTimePreset);
    RETURN;
END_IF;

(* System Start *)
IF StartButton AND NOT SystemActive AND (State = PizzaState.Idle) THEN
    SystemActive := TRUE;
    State := PizzaState.DoughRolling;
END_IF;

(* State Machine Execution *)
IF NOT SystemActive THEN
    State := PizzaState.Idle;
    DoughRollerMotor := FALSE;
    ToppingDispenser := FALSE;
    ConveyorMotor := FALSE;
    OvenHeater := FALSE;
    OvenTemperature := 0;
    ConveyorTimer(IN := FALSE, PT := ConveyorTimePreset);
    BakingTimer(IN := FALSE, PT := BakingTimePreset);
    CoolingTimer(IN := FALSE, PT := CoolingTimePreset);
    RETURN;
END_IF;

CASE State OF
    PizzaState.Idle:
        (* Wait for start *)
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        
    PizzaState.DoughRolling:
        (* Activate dough roller until dough is ready *)
        DoughRollerMotor := NOT DoughReadySensor;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        
        IF DoughReadySensor THEN
            State := PizzaState.ToppingDispensing;
        END_IF;
        
    PizzaState.ToppingDispensing:
        (* Activate topping dispenser until toppings are ready *)
        DoughRollerMotor := FALSE;
        ToppingDispenser := NOT ToppingsReadySensor;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        
        IF DoughReadySensor AND ToppingsReadySensor THEN
            State := PizzaState.ConveyingToOven;
            ConveyorTimer(IN := TRUE, PT := ConveyorTimePreset);
        END_IF;
        
    PizzaState.ConveyingToOven:
        (* Move pizza to oven for fixed time *)
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := TRUE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        
        ConveyorTimer(IN := TRUE, PT := ConveyorTimePreset);
        IF ConveyorTimer.Q THEN
            State := PizzaState.Baking;
            ConveyorTimer(IN := FALSE, PT := ConveyorTimePreset);
            BakingTimer(IN := TRUE, PT := BakingTimePreset);
        END_IF;
        
    PizzaState.Baking:
        (* Bake pizza at 220°C *)
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := TRUE;
        OvenTemperature := 220;
        
        BakingTimer(IN := TRUE, PT := BakingTimePreset);
        IF BakingDoneSensor OR BakingTimer.Q THEN
            State := PizzaState.Cooling;
            OvenHeater := FALSE;
            BakingTimer(IN := FALSE, PT := BakingTimePreset);
            CoolingTimer(IN := TRUE, PT := CoolingTimePreset);
        END_IF;
        
    PizzaState.Cooling:
        (* Cool oven to 0°C *)
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        
        CoolingTimer(IN := TRUE, PT := CoolingTimePreset);
        IF CoolingTimer.Q THEN
            State := PizzaState.Complete;
            CoolingTimer(IN := FALSE, PT := CoolingTimePreset);
        END_IF;
        
    PizzaState.Complete:
        (* Cycle complete, reset to idle *)
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        SystemActive := FALSE;
        State := PizzaState.Idle;
        
    ELSE
        (* Fallback to safe state *)
        State := PizzaState.Idle;
        SystemActive := FALSE;
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
END_CASE;

END_FUNCTION_BLOCK