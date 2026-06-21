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
    CurrentState : INT;  // 0=IDLE, 1=DOUGH_ROLLING, 2=TOPPING_DISPENSING, 3=CONVEYING_TO_OVEN, 4=BAKING, 5=COMPLETE, 6=EMERGENCY_STOP
    ConveyorTimer : TIME;
    ConveyorStartTime : TIME;
    CoolingTimer : TIME;
    CoolingStartTime : TIME;
    PrevStopButton : BOOL;
    FirstCycle : BOOL := TRUE;
END_VAR

// Initialization on first cycle
IF FirstCycle THEN
    CurrentState := 0;  // IDLE state
    DoughRollerMotor := FALSE;
    ToppingDispenser := FALSE;
    ConveyorMotor := FALSE;
    OvenHeater := FALSE;
    OvenTemperature := 0;
    ConveyorTimer := T#0s;
    CoolingTimer := T#0s;
    PrevStopButton := FALSE;
    FirstCycle := FALSE;
END_IF

// Emergency Stop handling (highest priority)
IF StopButton THEN
    CurrentState := 6;  // EMERGENCY_STOP
END_IF

// Main state machine
CASE CurrentState OF
    0: // IDLE
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        
        IF StartButton AND NOT StopButton THEN
            CurrentState := 1;  // Transition to DOUGH_ROLLING
        END_IF
        
    1: // DOUGH_ROLLING
        DoughRollerMotor := TRUE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        
        IF DoughReadySensor THEN
            CurrentState := 2;  // Transition to TOPPING_DISPENSING
        END_IF
        
    2: // TOPPING_DISPENSING
        DoughRollerMotor := FALSE;
        ToppingDispenser := TRUE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        
        IF ToppingsReadySensor THEN
            CurrentState := 3;  // Transition to CONVEYING_TO_OVEN
            ConveyorStartTime := TIME();  // Start conveyor timer
        END_IF
        
    3: // CONVEYING_TO_OVEN
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := TRUE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        
        // Simulate conveyor movement with timer (e.g., 5 seconds)
        ConveyorTimer := TIME() - ConveyorStartTime;
        IF ConveyorTimer >= T#5s THEN
            CurrentState := 4;  // Transition to BAKING
        END_IF
        
    4: // BAKING
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := TRUE;
        OvenTemperature := 220;  // Maintain baking temperature
        
        IF BakingDoneSensor THEN
            CurrentState := 5;  // Transition to COMPLETE
            CoolingStartTime := TIME();  // Start cooling timer
        END_IF
        
    5: // COMPLETE
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        
        // Simulate cooling process
        CoolingTimer := TIME() - CoolingStartTime;
        IF CoolingTimer >= T#10s THEN  // Cooling complete after 10 seconds
            OvenTemperature := 0;
            CurrentState := 0;  // Transition back to IDLE
        ELSIF CoolingTimer >= T#5s THEN
            OvenTemperature := 50;  // Intermediate cooling
        ELSE
            OvenTemperature := 100;  // Initial cooling
        END_IF
        
    6: // EMERGENCY_STOP
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        OvenHeater := FALSE;
        OvenTemperature := 0;
        
        // Manual reset required
        IF NOT StopButton AND NOT StartButton THEN
            CurrentState := 0;  // Transition back to IDLE
        END_IF
        
END_CASE

// Store previous stop button state for edge detection
PrevStopButton := StopButton;

END_FUNCTION_BLOCK