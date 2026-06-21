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
    WaterHeatingDuration : DINT := 30000; (* 30 seconds in milliseconds *)
    GrinderDuration : DINT := 15000; (* 15 seconds in milliseconds *)
    BrewingDuration : DINT := 60000; (* 60 seconds in milliseconds *)
    state : INT; (* Current state: 0=IDLE, 1=HEATING_WATER, 2=GRINDING_BEANS, 3=BREWING_COFFEE *)
    prevState : INT; (* Previous state for edge detection *)
    processStartTime : DINT; (* Timestamp when current process started *)
    internalElapsedTime : DINT; (* Calculated elapsed time for current process *)
END_VAR

(* State machine implementation *)
IF NOT StartButton THEN
    (* Reset condition: StartButton is FALSE *)
    state := 0;
    prevState := 0;
    processStartTime := 0;
    internalElapsedTime := 0;
    WaterHeating := FALSE;
    GrinderRunning := FALSE;
    Brewing := FALSE;
    WaterHeated := FALSE;
    GrinderFinished := FALSE;
    CoffeeReady := FALSE;
ELSE
    (* Calculate internal elapsed time based on state change *)
    IF state <> prevState THEN
        (* State changed, reset timer for new process *)
        processStartTime := ElapsedTime;
        internalElapsedTime := 0;
        prevState := state;
    ELSE
        (* Same state, calculate elapsed time for current process *)
        internalElapsedTime := ElapsedTime - processStartTime;
    END_IF;

    (* State transitions *)
    CASE state OF
        0: (* IDLE *)
            IF StartButton THEN
                state := 1; (* Transition to HEATING_WATER *)
                processStartTime := ElapsedTime;
                internalElapsedTime := 0;
            END_IF;

        1: (* HEATING_WATER *)
            IF internalElapsedTime >= WaterHeatingDuration THEN
                state := 2; (* Transition to GRINDING_BEANS *)
                processStartTime := ElapsedTime;
                internalElapsedTime := 0;
            END_IF;

        2: (* GRINDING_BEANS *)
            IF internalElapsedTime >= GrinderDuration THEN
                state := 3; (* Transition to BREWING_COFFEE *)
                processStartTime := ElapsedTime;
                internalElapsedTime := 0;
            END_IF;

        3: (* BREWING_COFFEE *)
            IF internalElapsedTime >= BrewingDuration THEN
                state := 0; (* Transition back to IDLE *)
                processStartTime := ElapsedTime;
                internalElapsedTime := 0;
            END_IF;
    END_CASE;

    (* Set outputs based on current state *)
    CASE state OF
        0: (* IDLE *)
            WaterHeating := FALSE;
            GrinderRunning := FALSE;
            Brewing := FALSE;
            WaterHeated := FALSE;
            GrinderFinished := FALSE;
            CoffeeReady := FALSE;

        1: (* HEATING_WATER *)
            WaterHeating := TRUE;
            GrinderRunning := FALSE;
            Brewing := FALSE;
            WaterHeated := FALSE;
            GrinderFinished := FALSE;
            CoffeeReady := FALSE;

        2: (* GRINDING_BEANS *)
            WaterHeating := FALSE;
            GrinderRunning := TRUE;
            Brewing := FALSE;
            WaterHeated := TRUE;
            GrinderFinished := FALSE;
            CoffeeReady := FALSE;

        3: (* BREWING_COFFEE *)
            WaterHeating := FALSE;
            GrinderRunning := FALSE;
            Brewing := TRUE;
            WaterHeated := TRUE;
            GrinderFinished := TRUE;
            CoffeeReady := FALSE;
    END_CASE;
END_IF;

END_FUNCTION_BLOCK
END_ST