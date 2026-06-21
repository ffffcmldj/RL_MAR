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
                WaterHeating := TRUE;
                ProcessStartTime := ElapsedTime;
                CurrentState := 1;
            END_IF;
            
        1: (* Water Heating *)
            WaterHeating := TRUE;
            GrinderRunning := FALSE;
            Brewing := FALSE;
            
            IF (ElapsedTime - ProcessStartTime) >= WaterHeatingDuration THEN
                WaterHeating := FALSE;
                WaterHeated := TRUE;
                ProcessStartTime := ElapsedTime;
                CurrentState := 2;
            END_IF;
            
        2: (* Grinder Running *)
            WaterHeating := FALSE;
            GrinderRunning := TRUE;
            Brewing := FALSE;
            
            IF (ElapsedTime - ProcessStartTime) >= GrinderDuration THEN
                GrinderRunning := FALSE;
                GrinderFinished := TRUE;
                ProcessStartTime := ElapsedTime;
                CurrentState := 3;
            END_IF;
            
        3: (* Brewing *)
            WaterHeating := FALSE;
            GrinderRunning := FALSE;
            Brewing := TRUE;
            
            IF (ElapsedTime - ProcessStartTime) >= BrewingDuration THEN
                Brewing := FALSE;
                CoffeeReady := TRUE;
                CurrentState := 4;
            END_IF;
            
        4: (* Process Complete *)
            WaterHeating := FALSE;
            GrinderRunning := FALSE;
            Brewing := FALSE;
            (* Keep status indicators active until reset *)
            
        ELSE
            CurrentState := 0;
    END_CASE;
END_IF;

END_FUNCTION_BLOCK