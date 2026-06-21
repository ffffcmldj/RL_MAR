ructured-text
START_ST
FUNCTION_BLOCK CoffeeMachineControl
VAR_INPUT
    StartButton : BOOL;
    ElapsedTime : DINT; (* Time elapsed since the start of the current process, in milliseconds *)
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
    state : INT; (* Current state variable *)
    prevState : INT; (* Previous state variable *)
    WaterHeatingDuration : DINT := 30000; (* 30 seconds in milliseconds *)
    GrinderDuration : DINT := 15000; (* 15 seconds in milliseconds *)
    BrewingDuration : DINT := 60000; (* 60 seconds in milliseconds *)
END_VAR

(* State definitions *)
CONST
    IDLE : INT := 0;
    HEATING_WATER : INT := 1;
    WATER_HEATED : INT := 2;
    GRINDING : INT := 3;
    GRINDER_FINISHED : INT := 4;
    BREWING : INT := 5;
    COFFEE_READY : INT := 6;
END_CONST

(* State machine logic *)
CASE state OF
    IDLE:
        WaterHeating := FALSE;
        GrinderRunning := FALSE;
        Brewing := FALSE;
        WaterHeated := FALSE;
        GrinderFinished := FALSE;
        CoffeeReady := FALSE;
        IF StartButton THEN
            state := HEATING_WATER;
        END_IF;

    HEATING_WATER:
        WaterHeating := TRUE;
        GrinderRunning := FALSE;
        Brewing := FALSE;
        WaterHeated := FALSE;
        GrinderFinished := FALSE;
        CoffeeReady := FALSE;
        IF ElapsedTime >= WaterHeatingDuration THEN
            WaterHeated := TRUE;
            state := WATER_HEATED;
        END_IF;

    WATER_HEATED:
        WaterHeating := FALSE;
        GrinderRunning := FALSE;
        Brewing := FALSE;
        WaterHeated := TRUE;
        GrinderFinished := FALSE;
        CoffeeReady := FALSE;
        state := GRINDING;

    GRINDING:
        WaterHeating := FALSE;
        GrinderRunning := TRUE;
        Brewing := FALSE;
        WaterHeated := TRUE;
        GrinderFinished := FALSE;
        CoffeeReady := FALSE;
        IF ElapsedTime >= GrinderDuration THEN
            GrinderFinished := TRUE;
            state := GRINDER_FINISHED;
        END_IF;

    GRINDER_FINISHED:
        WaterHeating := FALSE;
        GrinderRunning := FALSE;
        Brewing := FALSE;
        WaterHeated := TRUE;
        GrinderFinished := TRUE;
        CoffeeReady := FALSE;
        state := BREWING;

    BREWING:
        WaterHeating := FALSE;
        GrinderRunning := FALSE;
        Brewing := TRUE;
        WaterHeated := TRUE;
        GrinderFinished := TRUE;
        CoffeeReady := FALSE;
        IF ElapsedTime >= BrewingDuration THEN
            CoffeeReady := TRUE;
            state := COFFEE_READY;
        END_IF;

    COFFEE_READY:
        WaterHeating := FALSE;
        GrinderRunning := FALSE;
        Brewing := FALSE;
        WaterHeated := TRUE;
        GrinderFinished := TRUE;
        CoffeeReady := TRUE;
        IF NOT StartButton THEN
            state := IDLE;
        END_IF;

ELSE
    (* Reset to IDLE if StartButton is not pressed *)
    IF NOT StartButton THEN
        state := IDLE;
    END_IF;
END_CASE;

END_FUNCTION_BLOCK
END_ST