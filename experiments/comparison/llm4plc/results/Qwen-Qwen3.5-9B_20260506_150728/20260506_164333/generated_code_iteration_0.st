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
    CurrentState : INT; (* 0:IDLE, 1:HEATING_WATER, 2:GRINDING, 3:BREWING, 4:READY *)
    WaterHeatingDuration : DINT := 30000; (* 30 seconds in milliseconds *)
    GrinderDuration : DINT := 15000; (* 15 seconds in milliseconds *)
    BrewingDuration : DINT := 60000; (* 60 seconds in milliseconds *)
END_VAR

BEGIN
    (* Reset logic if StartButton is not pressed *)
    IF StartButton = FALSE THEN
        CurrentState := 0; (* IDLE *)
        WaterHeating := FALSE;
        GrinderRunning := FALSE;
        Brewing := FALSE;
        WaterHeated := FALSE;
        GrinderFinished := FALSE;
        CoffeeReady := FALSE;
    ELSE
        (* Process logic based on current state *)
        CASE CurrentState OF
            0: (* STATE 0: IDLE *)
                (* Wait for StartButton to be pressed *)
                WaterHeating := FALSE;
                GrinderRunning := FALSE;
                Brewing := FALSE;
                WaterHeated := FALSE;
                GrinderFinished := FALSE;
                CoffeeReady := FALSE;

            1: (* STATE 1: HEATING_WATER *)
                WaterHeating := TRUE;
                GrinderRunning := FALSE;
                Brewing := FALSE;
                WaterHeated := FALSE;
                GrinderFinished := FALSE;
                CoffeeReady := FALSE;

                (* Check exit condition for heating *)
                IF ElapsedTime >= WaterHeatingDuration THEN
                    CurrentState := 2; (* Transition to GRINDING *)
                END_IF;

            2: (* STATE 2: GRINDING *)
                WaterHeating := FALSE;
                GrinderRunning := TRUE;
                Brewing := FALSE;
                WaterHeated := TRUE; (* Set when entering this state *)
                GrinderFinished := FALSE;
                CoffeeReady := FALSE;

                (* Check exit condition for grinding *)
                IF ElapsedTime >= GrinderDuration THEN
                    CurrentState := 3; (* Transition to BREWING *)
                END_IF;

            3: (* STATE 3: BREWING *)
                WaterHeating := FALSE;
                GrinderRunning := FALSE;
                Brewing := TRUE;
                WaterHeated := TRUE;
                GrinderFinished := TRUE; (* Set when entering this state *)
                CoffeeReady := FALSE;

                (* Check exit condition for brewing *)
                IF ElapsedTime >= BrewingDuration THEN
                    CurrentState := 4; (* Transition to READY *)
                END_IF;

            4: (* STATE 4: READY *)
                WaterHeating := FALSE;
                GrinderRunning := FALSE;
                Brewing := FALSE;
                WaterHeated := TRUE;
                GrinderFinished := TRUE;
                CoffeeReady := TRUE;
        END_CASE;
    END_IF;
END_FUNCTION_BLOCK
END_ST