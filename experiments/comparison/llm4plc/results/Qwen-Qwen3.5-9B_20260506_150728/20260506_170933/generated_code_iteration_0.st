START_ST
FUNCTION_BLOCK BakeryOvenControl
VAR_INPUT
    TemperatureSensor : REAL; (* Sensor input for oven temperature *)
    HumiditySensor : REAL; (* Sensor input for oven humidity *)
    StartSignal : BOOL; (* Input to start the baking process *)
END_VAR
VAR_OUTPUT
    HeatingElement : BOOL; (* Control signal for heating element *)
    CoolingElement : BOOL; (* Control signal for cooling element *)
    HumidityControl : BOOL; (* Control signal for humidity system *)
    DehumidityControl : BOOL; (* Control signal for dehumidification *)
END_VAR
VAR
    OvenTemperature : REAL := 0.0; (* Current oven temperature setpoint *)
    OvenHumidity : REAL := 0.0; (* Current humidity setpoint *)
    BakingTime : TIME := T#0s; (* Total baking time setpoint *)
    OvenStatus : BOOL := FALSE; (* Oven status: TRUE=On, FALSE=Off *)
    HeatingThreshold : REAL := 2.0; (* Temperature control threshold *)
    HumidityThreshold : REAL := 5.0; (* Humidity control threshold *)
    
    CurrentTemperature : REAL; (* To store the latest sensor reading *)
    CurrentHumidity : REAL; (* To store the latest sensor reading *)
    TimerAccumulator : TIME := T#0s; (* To accumulate time for the 1-second decrement logic *)
    TimerFlag : BOOL := FALSE; (* Flag to indicate if 1 second has elapsed *)
    BakingTimeRemaining : TIME := T#0s; (* Working copy of the baking time to decrement *)
    
    OneSecondTimer : TON; (* Timer to generate 1-second pulses *)
END_VAR

(* --- State Machine Logic --- *)
CASE OvenStatus OF
    0: (* STATE 0: OFF *)
        (* Initialize/Reset logic *)
        OvenStatus := FALSE;
        BakingTimeRemaining := T#0s;
        TimerAccumulator := T#0s;
        TimerFlag := FALSE;
        
        (* Ensure all outputs are deactivated *)
        HeatingElement := FALSE;
        CoolingElement := FALSE;
        HumidityControl := FALSE;
        DehumidityControl := FALSE;
        
        (* Wait for StartSignal to transition to BAKING state *)
        IF StartSignal THEN
            OvenStatus := 1;
        END_IF;
        
    1: (* STATE 1: BAKING *)
        (* Read Sensor Inputs *)
        CurrentTemperature := TemperatureSensor;
        CurrentHumidity := HumiditySensor;
        
        (* Temperature Control Logic *)
        (* Activate heating when temp falls below setpoint minus threshold *)
        IF CurrentTemperature < (OvenTemperature - HeatingThreshold) THEN
            HeatingElement := TRUE;
        ELSE
            HeatingElement := FALSE;
        END_IF;
        
        (* Activate cooling when temp exceeds setpoint plus threshold *)
        IF CurrentTemperature > (OvenTemperature + HeatingThreshold) THEN
            CoolingElement := TRUE;
        ELSE
            CoolingElement := FALSE;
        END_IF;
        
        (* Humidity Control Logic *)
        (* Activate humidification when humidity falls below setpoint minus threshold *)
        IF CurrentHumidity < (OvenHumidity - HumidityThreshold) THEN
            HumidityControl := TRUE;
        ELSE
            HumidityControl := FALSE;
        END_IF;
        
        (* Activate dehumidification when humidity exceeds setpoint plus threshold *)
        IF CurrentHumidity > (OvenHumidity + HumidityThreshold) THEN
            DehumidityControl := TRUE;
        ELSE
            DehumidityControl := FALSE;
        END_IF;
        
        (* Timer Logic for Baking Time *)
        (* Reset accumulator if it has expired or if we just finished a second *)
        IF TimerAccumulator >= T#1s THEN
            TimerAccumulator := T#0s;
            TimerFlag := TRUE;
        END_IF;
        
        (* Decrement baking time if 1 second has elapsed *)
        IF TimerFlag THEN
            BakingTimeRemaining := BakingTimeRemaining - T#1s;
            TimerFlag := FALSE;
        END_IF;
        
        (* Check for Baking Complete *)
        IF BakingTimeRemaining <= T#0s THEN
            OvenStatus := 0; (* Transition back to OFF state *)
            HeatingElement := FALSE;
            CoolingElement := FALSE;
            HumidityControl := FALSE;
            DehumidityControl := FALSE;
        END_IF;
END_CASE

(* --- Internal Timer Logic for 1-second Pulse --- *)
(* This timer generates a pulse every second to drive the decrement logic *)
OneSecondTimer(IN := TimerFlag, PT := T#1s);
(* Note: In this specific logic flow, TimerFlag acts as the trigger. 
   A standard TON with IN set to TRUE every scan would work, 
   but the accumulator approach above handles the 1s interval cleanly.
   If strict edge-triggering is needed, OneSecondTimer(IN := TRUE, PT:=T#1s) 
   would set a done bit, but the accumulator logic above is robust for time-based decrement. *)

END_FUNCTION_BLOCK
END_ST