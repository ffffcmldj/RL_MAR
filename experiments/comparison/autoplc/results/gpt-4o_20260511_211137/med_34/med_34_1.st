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
    END_VAR

    (* Initialization: Reset all outputs if the start button is not pressed *)
    IF NOT StartButton THEN
        WaterHeating := FALSE;
        GrinderRunning := FALSE;
        Brewing := FALSE;
        WaterHeated := FALSE;
        GrinderFinished := FALSE;
        CoffeeReady := FALSE;
    ELSE
        (* Water Heating Logic *)
        IF NOT WaterHeated THEN
            IF ElapsedTime < WaterHeatingDuration THEN
                WaterHeating := TRUE;
            ELSE
                WaterHeating := FALSE;
                WaterHeated := TRUE;
            END_IF
        END_IF

        (* Grinding Logic *)
        IF WaterHeated AND NOT GrinderFinished THEN
            IF ElapsedTime < GrinderDuration THEN
                GrinderRunning := TRUE;
            ELSE
                GrinderRunning := FALSE;
                GrinderFinished := TRUE;
            END_IF
        END_IF

        (* Brewing Logic *)
        IF GrinderFinished AND NOT CoffeeReady THEN
            IF ElapsedTime < BrewingDuration THEN
                Brewing := TRUE;
            ELSE
                Brewing := FALSE;
                CoffeeReady := TRUE;
            END_IF
        END_IF
    END_IF
END_FUNCTION_BLOCK