FUNCTION_BLOCK GreenhouseWateringSystem
VAR_INPUT
    SoilMoistureSensor : REAL;   (* Input for soil moisture level (0-100%) *)
END_VAR
VAR_OUTPUT
    SprinklersOn : BOOL := FALSE; (* Output for controlling sprinklers - on/off *)
END_VAR
VAR
    ResponseDelay : TIME := T#5s;  (* Example response delay for the system *)
    LastMoistureReading : REAL;
    tDelay : TON;
    bDelayActive : BOOL := FALSE;
    eState : (eIdle, eActivating, eActive, eDeactivating) := eIdle;
END_VAR

(* Timer initialization *)
tDelay(IN:=bDelayActive, PT:=ResponseDelay);

(* Main state machine logic *)
CASE eState OF
    eIdle:
        SprinklersOn := FALSE;
        bDelayActive := FALSE;
        LastMoistureReading := SoilMoistureSensor;
        
        IF SoilMoistureSensor < 30.0 THEN
            eState := eActivating;
            bDelayActive := TRUE;
        ELSIF SoilMoistureSensor > 70.0 THEN
            eState := eIdle; (* Already in idle, but kept for clarity *)
        END_IF;
        
    eActivating:
        SprinklersOn := FALSE;
        LastMoistureReading := SoilMoistureSensor;
        
        IF tDelay.Q THEN
            eState := eActive;
            bDelayActive := FALSE;
        END_IF;
        
        IF SoilMoistureSensor > 70.0 THEN
            eState := eIdle;
            bDelayActive := FALSE;
        END_IF;
        
    eActive:
        SprinklersOn := TRUE;
        bDelayActive := FALSE;
        LastMoistureReading := SoilMoistureSensor;
        
        IF SoilMoistureSensor > 70.0 THEN
            eState := eDeactivating;
            bDelayActive := TRUE;
        END_IF;
        
    eDeactivating:
        SprinklersOn := TRUE;
        LastMoistureReading := SoilMoistureSensor;
        
        IF tDelay.Q THEN
            eState := eIdle;
            bDelayActive := FALSE;
        END_IF;
        
        IF SoilMoistureSensor < 30.0 THEN
            eState := eActive;
            bDelayActive := FALSE;
        END_IF;
        
END_CASE;
END_FUNCTION_BLOCK