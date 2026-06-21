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
    CurrentState : INT := 0; (* 0: Idle, 1: Water Heating, 2: Grinding, 3: Brewing, 4: Completed *)
END_VAR

(* Main control logic *)
IF NOT StartButton THEN
    (* Reset all outputs when the start button is not pressed *)
    WaterHeating := FALSE;
    GrinderRunning := FALSE;
    Brewing := FALSE;
    GrinderFinished := FALSE;
    WaterHeated := FALSE;
    CoffeeReady := FALSE;
    CurrentState := 0; (* Go back to Idle state *)
ELSE
    CASE CurrentState OF
        0: (* Idle State *)
            IF NOT WaterHeated THEN
                CurrentState := 1; (* Transition to Water Heating *)
            END_IF
            
        1: (* Water Heating State *)
            WaterHeating := TRUE;
            ElapsedTime := ElapsedTime + 100; (* Simulate elapsed time increment, assuming this block is called every 100 ms *)
            IF ElapsedTime >= WaterHeatingDuration THEN
                WaterHeated := TRUE;
                WaterHeating := FALSE;
                CurrentState := 2; (* Transition to Grinding *)
                ElapsedTime := 0; (* Reset elapsed time for next process *)
            END_IF
            
        2: (* Grinding State *)
            GrinderRunning := TRUE;
            ElapsedTime := ElapsedTime + 100; (* Simulate elapsed time increment *)
            IF ElapsedTime >= GrinderDuration THEN
                GrinderFinished := TRUE;
                GrinderRunning := FALSE;
                CurrentState := 3; (* Transition to Brewing *)
                ElapsedTime := 0; (* Reset elapsed time for next process *)
            END_IF
            
        3: (* Brewing State *)
            Brewing := TRUE;
            ElapsedTime := ElapsedTime + 100; (* Simulate elapsed time increment *)
            IF ElapsedTime >= BrewingDuration THEN
                CoffeeReady := TRUE;
                Brewing := FALSE;
                CurrentState := 4; (* Transition to Completed *)
                ElapsedTime := 0; (* Reset elapsed time for next process *)
            END_IF
            
        4: (* Completed State *)
            (* All processes are finished, remain in this state until StartButton is not pressed *)
            (* No action needed here, just wait for the next cycle *)
    END_CASE
END_IF

END_FUNCTION_BLOCK