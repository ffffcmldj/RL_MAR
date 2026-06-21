(* Global state definitions - placed outside the FUNCTION_BLOCK *)
CONST
    STATE_IDLE : INT := 0;
    STATE_HEATING : INT := 1;
    STATE_GRINDING : INT := 2;
    STATE_BREWING : INT := 3;
    STATE_COMPLETE : INT := 4;
END_CONST

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
    CurrentState : INT; (* 0=IDLE, 1=HEATING, 2=GRINDING, 3=BREWING, 4=COMPLETE *)
    StartButtonPrev : BOOL;
END_VAR

(* Main execution logic *)
IF NOT StartButton THEN
    (* Reset all outputs and state when StartButton is not pressed *)
    CurrentState := STATE_IDLE;
    WaterHeating := FALSE;
    GrinderRunning := FALSE;
    Brewing := FALSE;
    WaterHeated := FALSE;
    GrinderFinished := FALSE;
    CoffeeReady := FALSE;
    StartButtonPrev := FALSE;
ELSE
    (* Detect rising edge of StartButton *)
    IF NOT StartButtonPrev AND StartButton THEN
        (* Start the process from IDLE state *)
        IF CurrentState = STATE_IDLE THEN
            CurrentState := STATE_HEATING;
            WaterHeated := FALSE;
            GrinderFinished := FALSE;
            CoffeeReady := FALSE;
        END_IF;
    END_IF;
    
    (* Update previous state of StartButton *)
    StartButtonPrev := StartButton;
    
    (* State machine execution *)
    CASE CurrentState OF
        STATE_IDLE:
            (* Do nothing, wait for start *)
            WaterHeating := FALSE;
            GrinderRunning := FALSE;
            Brewing := FALSE;
            
        STATE_HEATING:
            (* Activate water heating *)
            WaterHeating := TRUE;
            GrinderRunning := FALSE;
            Brewing := FALSE;
            
            (* Check if heating duration is reached *)
            IF ElapsedTime >= WaterHeatingDuration THEN
                WaterHeated := TRUE;
                WaterHeating := FALSE;
                CurrentState := STATE_GRINDING;
            END_IF;
            
        STATE_GRINDING:
            (* Activate grinder *)
            WaterHeating := FALSE;
            GrinderRunning := TRUE;
            Brewing := FALSE;
            
            (* Check if grinding duration is reached *)
            IF ElapsedTime >= GrinderDuration THEN
                GrinderFinished := TRUE;
                GrinderRunning := FALSE;
                CurrentState := STATE_BREWING;
            END_IF;
            
        STATE_BREWING:
            (* Activate brewing *)
            WaterHeating := FALSE;
            GrinderRunning := FALSE;
            Brewing := TRUE;
            
            (* Check if brewing duration is reached *)
            IF ElapsedTime >= BrewingDuration THEN
                CoffeeReady := TRUE;
                Brewing := FALSE;
                CurrentState := STATE_COMPLETE;
            END_IF;
            
        STATE_COMPLETE:
            (* Coffee is ready, maintain status *)
            WaterHeating := FALSE;
            GrinderRunning := FALSE;
            Brewing := FALSE;
            (* Keep CoffeeReady as TRUE *)
            
    END_CASE;
END_IF;

END_FUNCTION_BLOCK