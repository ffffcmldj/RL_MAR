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
    CurrentState : INT;
    StateIDLE : INT := 0;
    StateDoughRolling : INT := 1;
    StateToppingDispensing : INT := 2;
    StateBaking : INT := 3;
    StateDone : INT := 4;
    PreviousStopButton : BOOL;
    PreviousStartButton : BOOL;
    PreviousDoughReadySensor : BOOL;
    PreviousToppingsReadySensor : BOOL;
    PreviousBakingDoneSensor : BOOL;
END_VAR


    PreviousStopButton := StopButton;
    PreviousStartButton := StartButton;
    PreviousDoughReadySensor := DoughReadySensor;
    PreviousToppingsReadySensor := ToppingsReadySensor;
    PreviousBakingDoneSensor := BakingDoneSensor;

    IF StopButton = TRUE THEN
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        CurrentState := StateIDLE;
    ELSIF CurrentState = StateIDLE THEN
        IF StartButton = TRUE THEN
            CurrentState := StateDoughRolling;
        END_IF;
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
    ELSIF CurrentState = StateDoughRolling THEN
        DoughRollerMotor := TRUE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        IF PreviousDoughReadySensor = FALSE AND DoughReadySensor = TRUE THEN
            CurrentState := StateToppingDispensing;
        END_IF;
    ELSIF CurrentState = StateToppingDispensing THEN
        DoughRollerMotor := FALSE;
        ToppingDispenser := TRUE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        IF PreviousToppingsReadySensor = FALSE AND ToppingsReadySensor = TRUE THEN
            CurrentState := StateBaking;
        END_IF;
    ELSIF CurrentState = StateBaking THEN
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := TRUE;
        OvenHeater := TRUE;
        OvenTemperature := 220;
        IF PreviousBakingDoneSensor = FALSE AND BakingDoneSensor = TRUE THEN
            CurrentState := StateDone;
        END_IF;
    ELSIF CurrentState = StateDone THEN
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
    END_IF;
END_FUNCTION_BLOCK