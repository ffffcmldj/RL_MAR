plaintext
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
    state : INT := 0; (* Current state of the coffee machine *)
    prevState : INT := 0; (* Previous state of the coffee machine *)
    WaterHeatingDuration : DINT := 30000; (* 30 seconds in milliseconds *)
    GrinderDuration : DINT := 15000; (* 15 seconds in milliseconds *)
    BrewingDuration : DINT := 60000; (* 60 seconds in milliseconds *)
END_VAR

(* Main logic *)
IF NOT StartButton THEN
    (* Reset to IDLE state if StartButton is not pressed *)
    state := 0;
END_IF

CASE state OF
    0: (* IDLE state *)
        WaterHeating := FALSE;
        GrinderRunning := FALSE;
        Brewing := FALSE;
        WaterHeated := FALSE;
        GrinderFinished := FALSE;
        CoffeeReady := FALSE;

        IF StartButton AND NOT WaterHeated THEN
            state := 1; (* Transition to WATER HEATING state *)
        END_IF;

    1: (* WATER HEATING state *)
        WaterHeating := TRUE;
        GrinderRunning := FALSE;
        Brewing := FALSE;
        WaterHeated := FALSE;
        GrinderFinished := FALSE;
        CoffeeReady := FALSE;

        IF ElapsedTime >= WaterHeatingDuration THEN
            WaterHeated := TRUE;
            WaterHeating := FALSE;
            state := 2; (* Transition to GRINDING state *)
        END_IF;

        IF NOT StartButton THEN
            state := 0; (* Transition back to IDLE state *)
        END_IF;

    2: (* GRINDING state *)
        WaterHeating := FALSE;
        GrinderRunning := TRUE;
        Brewing := FALSE;
        WaterHeated := TRUE;
        GrinderFinished := FALSE;
        CoffeeReady := FALSE;

        IF ElapsedTime >= GrinderDuration THEN
            GrinderFinished := TRUE;
            GrinderRunning := FALSE;
            state := 3; (* Transition to BREWING state *)
        END_IF;

        IF NOT StartButton THEN
            state := 0; (* Transition back to IDLE state *)
        END_IF;

    3: (* BREWING state *)
        WaterHeating := FALSE;
        GrinderRunning := FALSE;
        Brewing := TRUE;
        WaterHeated := TRUE;
        GrinderFinished := TRUE;
        CoffeeReady := FALSE;

        IF ElapsedTime >= BrewingDuration THEN
            CoffeeReady := TRUE;
            Brewing := FALSE;
            state := 0; (* Transition back to IDLE state *)
        END_IF;

        IF NOT StartButton THEN
            state := 0; (* Transition back to IDLE state *)
        END_IF;

END_CASE;

END_FUNCTION_BLOCK
END_ST