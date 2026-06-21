FUNCTION_BLOCK GreenhouseWateringSystem
VAR_INPUT
    SoilMoistureSensor : REAL; (* Input for soil moisture level (0-100%) *)
END_VAR

VAR_OUTPUT
    SprinklersOn : BOOL; (* Output for controlling sprinklers - on/off *)
END_VAR

VAR
    ResponseDelay : TIME := T#5s; (* Configurable response delay *)
    DelayTimer : TON; (* Timer for response delay *)
    LastMoistureReading : REAL; (* Stores previous moisture reading *)
    State : INT := 0; (* State machine state: 0=IDLE, 1=TRANSITION_TO_ON, 2=TRANSITION_TO_OFF *)
    TargetSprinklerState : BOOL; (* Target state for sprinklers after delay *)
END_VAR

(* Initialize outputs *)
SprinklersOn := FALSE;

(* Main state machine *)
CASE State OF
    0: (* IDLE - Monitoring state *)
        (* Store current reading for potential future use *)
        LastMoistureReading := SoilMoistureSensor;
        
        (* Check thresholds and initiate transitions if needed *)
        IF SoilMoistureSensor < 30.0 AND NOT SprinklersOn THEN
            (* Start transition to turn sprinklers ON *)
            TargetSprinklerState := TRUE;
            DelayTimer(IN := TRUE, PT := ResponseDelay);
            State := 1;
        ELSIF SoilMoistureSensor > 70.0 AND SprinklersOn THEN
            (* Start transition to turn sprinklers OFF *)
            TargetSprinklerState := FALSE;
            DelayTimer(IN := TRUE, PT := ResponseDelay);
            State := 2;
        ELSE
            (* No transition needed, ensure timer is reset *)
            DelayTimer(IN := FALSE);
        END_IF;
        
    1: (* TRANSITION_TO_ON - Waiting to turn sprinklers on *)
        (* Sprinklers remain OFF during transition *)
        SprinklersOn := FALSE;
        
        (* Check if timer has elapsed *)
        IF DelayTimer.Q THEN
            (* Timer elapsed - complete transition *)
            SprinklersOn := TargetSprinklerState; (* = TRUE *)
            DelayTimer(IN := FALSE);
            State := 0;
        ELSIF SoilMoistureSensor >= 30.0 THEN
            (* Moisture rose above threshold during delay - cancel transition *)
            DelayTimer(IN := FALSE);
            State := 0;
        END_IF;
        
    2: (* TRANSITION_TO_OFF - Waiting to turn sprinklers off *)
        (* Sprinklers remain ON during transition *)
        SprinklersOn := TRUE;
        
        (* Check if timer has elapsed *)
        IF DelayTimer.Q THEN
            (* Timer elapsed - complete transition *)
            SprinklersOn := TargetSprinklerState; (* = FALSE *)
            DelayTimer(IN := FALSE);
            State := 0;
        ELSIF SoilMoistureSensor <= 70.0 THEN
            (* Moisture dropped below threshold during delay - cancel transition *)
            DelayTimer(IN := FALSE);
            State := 0;
        END_IF;
END_CASE;

END_FUNCTION_BLOCK;