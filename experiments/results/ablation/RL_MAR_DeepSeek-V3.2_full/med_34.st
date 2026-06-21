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
    CurrentState : INT := 0;
    ProcessStartTime : DINT := 0;
    WaterHeatingDuration : DINT := 30000;
    GrinderDuration : DINT := 15000;
    BrewingDuration : DINT := 60000;
    WaterHeatedFlag : BOOL := FALSE;
    GrinderFinishedFlag : BOOL := FALSE;
    CoffeeReadyFlag : BOOL := FALSE;
    ProcessActive : BOOL := FALSE;
END_VAR

(* State Definitions:
   0: Idle
   1: Water Heating
   2: Grinder Running
   3: Brewing
*)

(* Reset all outputs when StartButton is not pressed *)
IF NOT StartButton THEN
    CurrentState := 0;
    ProcessStartTime := 0;
    WaterHeating := FALSE;
    GrinderRunning := FALSE;
    Brewing := FALSE;
    WaterHeated := FALSE;
    GrinderFinished := FALSE;
    CoffeeReady := FALSE;
    WaterHeatedFlag := FALSE;
    GrinderFinishedFlag := FALSE;
    CoffeeReadyFlag := FALSE;
    ProcessActive := FALSE;
    RETURN;
END_IF;

(* Main state machine *)
CASE CurrentState OF
    0: (* Idle - Start water heating when button pressed and water not heated *)
        IF StartButton AND NOT WaterHeatedFlag THEN
            CurrentState := 1;
            ProcessStartTime := ElapsedTime;
            WaterHeating := TRUE;
            ProcessActive := TRUE;
        END_IF;
        
    1: (* Water Heating *)
        IF (ElapsedTime - ProcessStartTime) >= WaterHeatingDuration THEN
            WaterHeating := FALSE;
            WaterHeatedFlag := TRUE;
            WaterHeated := TRUE;
            CurrentState := 2;
            ProcessStartTime := ElapsedTime;
            GrinderRunning := TRUE;
        END_IF;
        
    2: (* Grinder Running *)
        IF (ElapsedTime - ProcessStartTime) >= GrinderDuration THEN
            GrinderRunning := FALSE;
            GrinderFinishedFlag := TRUE;
            GrinderFinished := TRUE;
            CurrentState := 3;
            ProcessStartTime := ElapsedTime;
            Brewing := TRUE;
        END_IF;
        
    3: (* Brewing *)
        IF (ElapsedTime - ProcessStartTime) >= BrewingDuration THEN
            Brewing := FALSE;
            CoffeeReadyFlag := TRUE;
            CoffeeReady := TRUE;
            CurrentState := 0;
            ProcessActive := FALSE;
        END_IF;
        
    ELSE
        CurrentState := 0;
END_CASE;

END_FUNCTION_BLOCK;