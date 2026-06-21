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
    CurrentState : INT := 0;
    ProcessStartTime : DINT := 0;
END_VAR

(* Reset all outputs when start button is not pressed *)
IF NOT StartButton THEN
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
        0: (* Idle - waiting for start *)
            WaterHeating := FALSE;
            GrinderRunning := FALSE;
            Brewing := FALSE;
            WaterHeated := FALSE;
            GrinderFinished := FALSE;
            CoffeeReady := FALSE;
            
            IF StartButton THEN
                CurrentState := 1;
                ProcessStartTime := ElapsedTime;
            END_IF;
            
        1: (* Water Heating State *)
            WaterHeating := TRUE;
            GrinderRunning := FALSE;
            Brewing := FALSE;
            WaterHeated := FALSE;
            
            IF (ElapsedTime - ProcessStartTime) >= WaterHeatingDuration THEN
                WaterHeating := FALSE;
                WaterHeated := TRUE;
                CurrentState := 2;
                ProcessStartTime := ElapsedTime;
            END_IF;
            
        2: (* Grinder Running State *)
            WaterHeating := FALSE;
            GrinderRunning := TRUE;
            Brewing := FALSE;
            GrinderFinished := FALSE;
            
            IF (ElapsedTime - ProcessStartTime) >= GrinderDuration THEN
                GrinderRunning := FALSE;
                GrinderFinished := TRUE;
                CurrentState := 3;
                ProcessStartTime := ElapsedTime;
            END_IF;
            
        3: (* Brewing State *)
            WaterHeating := FALSE;
            GrinderRunning := FALSE;
            Brewing := TRUE;
            CoffeeReady := FALSE;
            
            IF (ElapsedTime - ProcessStartTime) >= BrewingDuration THEN
                Brewing := FALSE;
                CoffeeReady := TRUE;
                CurrentState := 0;
                ProcessStartTime := 0;
            END_IF;
    END_CASE;
END_IF;

END_FUNCTION_BLOCK