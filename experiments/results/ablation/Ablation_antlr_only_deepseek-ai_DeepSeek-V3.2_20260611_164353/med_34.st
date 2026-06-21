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
    (* Timing constants *)
    WaterHeatingDuration : DINT := 30000; (* 30 seconds in milliseconds *)
    GrinderDuration : DINT := 15000; (* 15 seconds in milliseconds *)
    BrewingDuration : DINT := 60000; (* 60 seconds in milliseconds *)
    
    (* State management *)
    CurrentState : INT := 0; (* 0: Idle, 1: Heating, 2: Grinding, 3: Brewing *)
    ProcessStartTime : DINT := 0;
    
    (* Internal flags for process completion *)
    WaterHeatingDone : BOOL := FALSE;
    GrinderDone : BOOL := FALSE;
    BrewingDone : BOOL := FALSE;
END_VAR

(* Main state machine logic *)
IF NOT StartButton THEN
    (* Reset everything when start button is not pressed *)
    CurrentState := 0;
    ProcessStartTime := 0;
    WaterHeatingDone := FALSE;
    GrinderDone := FALSE;
    BrewingDone := FALSE;
    
    WaterHeating := FALSE;
    GrinderRunning := FALSE;
    Brewing := FALSE;
    WaterHeated := FALSE;
    GrinderFinished := FALSE;
    CoffeeReady := FALSE;
ELSE
    (* Process state machine *)
    CASE CurrentState OF
        0: (* Idle - waiting for start *)
            IF StartButton AND NOT WaterHeatingDone THEN
                CurrentState := 1;
                ProcessStartTime := ElapsedTime;
                WaterHeating := TRUE;
            END_IF;
            
        1: (* Water Heating *)
            WaterHeating := TRUE;
            WaterHeated := FALSE;
            
            IF (ElapsedTime - ProcessStartTime) >= WaterHeatingDuration THEN
                WaterHeating := FALSE;
                WaterHeatingDone := TRUE;
                WaterHeated := TRUE;
                CurrentState := 2;
                ProcessStartTime := ElapsedTime;
            END_IF;
            
        2: (* Grinding *)
            IF WaterHeatingDone AND NOT GrinderDone THEN
                GrinderRunning := TRUE;
                GrinderFinished := FALSE;
                
                IF (ElapsedTime - ProcessStartTime) >= GrinderDuration THEN
                    GrinderRunning := FALSE;
                    GrinderDone := TRUE;
                    GrinderFinished := TRUE;
                    CurrentState := 3;
                    ProcessStartTime := ElapsedTime;
                END_IF;
            END_IF;
            
        3: (* Brewing *)
            IF GrinderDone AND NOT BrewingDone THEN
                Brewing := TRUE;
                CoffeeReady := FALSE;
                
                IF (ElapsedTime - ProcessStartTime) >= BrewingDuration THEN
                    Brewing := FALSE;
                    BrewingDone := TRUE;
                    CoffeeReady := TRUE;
                    (* Stay in state 3 until reset *)
                END_IF;
            END_IF;
            
    END_CASE;
END_IF;

END_FUNCTION_BLOCK;