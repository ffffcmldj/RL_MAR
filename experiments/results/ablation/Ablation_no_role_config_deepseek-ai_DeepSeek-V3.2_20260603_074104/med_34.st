FUNCTION_BLOCK CoffeeMachineControl
VAR_INPUT
    StartButton : BOOL;
    ElapsedTime : DINT; (* Time elapsed since the start of the current process, in milliseconds *)
END_VAR

VAR_OUTPUT
    WaterHeating : BOOL;
    GrinderRunning : BOOL;
    Brewing : BOOL;
    WaterHeated : BOOL;
    GrinderFinished : BOOL;
    CoffeeReady : BOOL;
END_VAR

VAR
    WaterHeatingDuration : DINT := 30000; (* 30 seconds in milliseconds *)
    GrinderDuration : DINT := 15000; (* 15 seconds in milliseconds *)
    BrewingDuration : DINT := 60000; (* 60 seconds in milliseconds *)
    CurrentState : INT := 0; (* 0: Idle, 1: Heating, 2: Grinding, 3: Brewing *)
    ProcessStartTime : DINT := 0;
END_VAR

(* State machine implementation *)
IF NOT StartButton THEN
    (* Reset all outputs and states when start button is not pressed *)
    CurrentState := 0;
    ProcessStartTime := 0;
    WaterHeating := FALSE;
    GrinderRunning := FALSE;
    Brewing := FALSE;
    WaterHeated := FALSE;
    GrinderFinished := FALSE;
    CoffeeReady := FALSE;
ELSE
    CASE CurrentState OF
        0: (* Idle state - waiting for start *)
            WaterHeating := FALSE;
            GrinderRunning := FALSE;
            Brewing := FALSE;
            WaterHeated := FALSE;
            GrinderFinished := FALSE;
            CoffeeReady := FALSE;
            
            IF StartButton THEN
                (* Start water heating process *)
                CurrentState := 1;
                ProcessStartTime := ElapsedTime;
                WaterHeating := TRUE;
            END_IF;
            
        1: (* Water heating state *)
            WaterHeating := TRUE;
            GrinderRunning := FALSE;
            Brewing := FALSE;
            
            IF (ElapsedTime - ProcessStartTime) >= WaterHeatingDuration THEN
                (* Water heating completed *)
                WaterHeating := FALSE;
                WaterHeated := TRUE;
                CurrentState := 2;
                ProcessStartTime := ElapsedTime;
            END_IF;
            
        2: (* Grinding state *)
            WaterHeating := FALSE;
            GrinderRunning := TRUE;
            Brewing := FALSE;
            
            IF (ElapsedTime - ProcessStartTime) >= GrinderDuration THEN
                (* Grinding completed *)
                GrinderRunning := FALSE;
                GrinderFinished := TRUE;
                CurrentState := 3;
                ProcessStartTime := ElapsedTime;
            END_IF;
            
        3: (* Brewing state *)
            WaterHeating := FALSE;
            GrinderRunning := FALSE;
            Brewing := TRUE;
            
            IF (ElapsedTime - ProcessStartTime) >= BrewingDuration THEN
                (* Brewing completed *)
                Brewing := FALSE;
                CoffeeReady := TRUE;
                CurrentState := 0; (* Return to idle state *)
                ProcessStartTime := 0;
            END_IF;
            
    END_CASE;
END_IF;

END_FUNCTION_BLOCK