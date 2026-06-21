(*
    Coffee Machine Control Function Block
    Implements sequential control for water heating, grinding, and brewing
    Only one process active at a time
    Resets when start button is released
*)

FUNCTION_BLOCK CoffeeMachineControl
VAR_INPUT
    StartButton : BOOL;                    (* Start/run command *)
    ElapsedTime : DINT;                    (* Time elapsed since process start in ms *)
END_VAR

VAR_OUTPUT
    WaterHeating : BOOL;                   (* Control signal for water heater *)
    GrinderRunning : BOOL;                 (* Control signal for coffee grinder *)
    Brewing : BOOL;                        (* Control signal for brewing pump *)
    WaterHeated : BOOL;                    (* Status: Water heating complete *)
    GrinderFinished : BOOL;                (* Status: Grinding complete *)
    CoffeeReady : BOOL;                    (* Status: Brewing complete *)
END_VAR

VAR
    (* Process timing constants *)
    WaterHeatingDuration : DINT := 30000;  (* 30 seconds in milliseconds *)
    GrinderDuration : DINT := 15000;       (* 15 seconds in milliseconds *)
    BrewingDuration : DINT := 60000;       (* 60 seconds in milliseconds *)
    
    (* State management *)
    CurrentState : INT := 0;               (* 0=Idle, 1=Heating, 2=Grinding, 3=Brewing *)
    StateStartTime : DINT := 0;            (* Time when current state started *)
    PreviousStartButton : BOOL := FALSE;   (* Edge detection for start button *)
    
    (* Internal flags *)
    InternalWaterHeated : BOOL := FALSE;
    InternalGrinderFinished : BOOL := FALSE;
    InternalCoffeeReady : BOOL := FALSE;
END_VAR

(* Main control logic *)
IF NOT StartButton THEN
    (* Reset all outputs and state when start button is not pressed *)
    CurrentState := 0;
    StateStartTime := 0;
    WaterHeating := FALSE;
    GrinderRunning := FALSE;
    Brewing := FALSE;
    InternalWaterHeated := FALSE;
    InternalGrinderFinished := FALSE;
    InternalCoffeeReady := FALSE;
ELSE
    (* Detect rising edge of start button *)
    IF StartButton AND NOT PreviousStartButton AND CurrentState = 0 THEN
        (* Start new cycle from idle state *)
        CurrentState := 1;
        StateStartTime := ElapsedTime;
        InternalWaterHeated := FALSE;
        InternalGrinderFinished := FALSE;
        InternalCoffeeReady := FALSE;
    END_IF;
    
    (* State machine execution *)
    CASE CurrentState OF
        0: (* Idle State *)
            WaterHeating := FALSE;
            GrinderRunning := FALSE;
            Brewing := FALSE;
            
        1: (* Water Heating State *)
            WaterHeating := TRUE;
            GrinderRunning := FALSE;
            Brewing := FALSE;
            
            (* Check if heating duration completed *)
            IF (ElapsedTime - StateStartTime) >= WaterHeatingDuration THEN
                InternalWaterHeated := TRUE;
                WaterHeating := FALSE;
                CurrentState := 2;
                StateStartTime := ElapsedTime;
            END_IF;
            
        2: (* Grinding State *)
            WaterHeating := FALSE;
            GrinderRunning := TRUE;
            Brewing := FALSE;
            
            (* Check if grinding duration completed *)
            IF (ElapsedTime - StateStartTime) >= GrinderDuration THEN
                InternalGrinderFinished := TRUE;
                GrinderRunning := FALSE;
                CurrentState := 3;
                StateStartTime := ElapsedTime;
            END_IF;
            
        3: (* Brewing State *)
            WaterHeating := FALSE;
            GrinderRunning := FALSE;
            Brewing := TRUE;
            
            (* Check if brewing duration completed *)
            IF (ElapsedTime - StateStartTime) >= BrewingDuration THEN
                InternalCoffeeReady := TRUE;
                Brewing := FALSE;
                CurrentState := 0;  (* Return to idle after completion *)
            END_IF;
    END_CASE;
END_IF;

(* Update status outputs *)
WaterHeated := InternalWaterHeated;
GrinderFinished := InternalGrinderFinished;
CoffeeReady := InternalCoffeeReady;

(* Store previous start button state for edge detection *)
PreviousStartButton := StartButton;

END_FUNCTION_BLOCK;