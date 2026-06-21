FUNCTION_BLOCK CoffeeMachineControl
VAR_INPUT
    StartButton : BOOL;
    ElapsedTime : DINT;
END_VAR
VAR_OUTPUT
    WaterHeating : BOOL;
    GrinderRunning : BOOL;
    Brewing : BOOL;
    GrinderFinished : BOOL;
    WaterHeated : BOOL;
    CoffeeReady : BOOL;
END_VAR
VAR
    WaterHeatingDuration : DINT := 30000;
    GrinderDuration : DINT := 15000;
    BrewingDuration : DINT := 60000;
    CurrentState : DINT;
    PreviousStartButton : BOOL;
    ElapsedTimeCounter : DINT;
END_VAR

CurrentState := 0;
PreviousStartButton := StartButton;
ElapsedTimeCounter := 0;

IF CurrentState = 0 THEN
    WaterHeating := FALSE;
    GrinderRunning := FALSE;
    Brewing := FALSE;
    WaterHeated := FALSE;
    GrinderFinished := FALSE;
    CoffeeReady := FALSE;
ELSIF CurrentState = 1 THEN
    WaterHeating := TRUE;
    GrinderRunning := FALSE;
    Brewing := FALSE;
    WaterHeated := FALSE;
    GrinderFinished := FALSE;
    CoffeeReady := FALSE;
    IF ElapsedTime >= WaterHeatingDuration THEN
        CurrentState := 2;
        ElapsedTimeCounter := 0;
    END_IF;
ELSIF CurrentState = 2 THEN
    WaterHeating := FALSE;
    GrinderRunning := TRUE;
    Brewing := FALSE;
    WaterHeated := TRUE;
    GrinderFinished := FALSE;
    CoffeeReady := FALSE;
    IF ElapsedTime >= GrinderDuration THEN
        CurrentState := 3;
        ElapsedTimeCounter := 0;
    END_IF;
ELSIF CurrentState = 3 THEN
    WaterHeating := FALSE;
    GrinderRunning := FALSE;
    Brewing := TRUE;
    WaterHeated := TRUE;
    GrinderFinished := TRUE;
    CoffeeReady := FALSE;
    IF ElapsedTime >= BrewingDuration THEN
        CurrentState := 4;
        ElapsedTimeCounter := 0;
    END_IF;
ELSIF CurrentState = 4 THEN
    WaterHeating := FALSE;
    GrinderRunning := FALSE;
    Brewing := FALSE;
    WaterHeated := TRUE;
    GrinderFinished := TRUE;
    CoffeeReady := TRUE;
    IF StartButton = FALSE THEN
        CurrentState := 0;
        ElapsedTimeCounter := 0;
    END_IF;
END_IF;

IF StartButton = TRUE AND PreviousStartButton = FALSE THEN
    CurrentState := 1;
    ElapsedTimeCounter := 0;
END_IF;

IF StartButton = FALSE THEN
    CurrentState := 0;
    ElapsedTimeCounter := 0;
END_IF;

END_FUNCTION_BLOCK