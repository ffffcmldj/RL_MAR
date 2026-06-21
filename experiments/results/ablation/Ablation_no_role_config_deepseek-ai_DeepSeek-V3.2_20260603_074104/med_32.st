FUNCTION_BLOCK GreenhouseWateringSystem
VAR_INPUT
    SoilMoistureSensor : REAL;   (* Input for soil moisture level (0-100%) *)
    ResponseDelay : TIME := T#5s;  (* Example response delay for the system *)
END_VAR
VAR_OUTPUT
    SprinklersOn : BOOL;         (* Output for controlling sprinklers - on/off *)
END_VAR
VAR
    LastMoistureReading : REAL;
    MoistureThresholdLow : REAL := 30.0;
    MoistureThresholdHigh : REAL := 70.0;
    SystemState : INT := 0;
    DelayTimer : TON;
    DelayElapsed : BOOL;
END_VAR

(* Initialize sprinklers to off state *)
SprinklersOn := FALSE;

(* Store the last moisture reading *)
LastMoistureReading := SoilMoistureSensor;

(* Handle response delay using timer *)
DelayTimer(IN := NOT DelayElapsed, PT := ResponseDelay);
DelayElapsed := DelayTimer.Q;

(* Main control logic - only execute when delay has elapsed *)
IF DelayElapsed THEN
    (* Turn sprinklers ON when moisture is below low threshold *)
    IF SoilMoistureSensor < MoistureThresholdLow THEN
        SprinklersOn := TRUE;
    END_IF;
    
    (* Turn sprinklers OFF when moisture exceeds high threshold *)
    IF SoilMoistureSensor > MoistureThresholdHigh THEN
        SprinklersOn := FALSE;
    END_IF;
    
    (* Reset delay timer for next cycle *)
    DelayElapsed := FALSE;
END_IF;

(* State transition logic *)
CASE SystemState OF
    0: (* Initial/Idle state *)
        IF (NOT SprinklersOn) AND (SoilMoistureSensor < MoistureThresholdLow) THEN
            SystemState := 1; (* Transition to activating state *)
        ELSIF SprinklersOn AND (SoilMoistureSensor > MoistureThresholdHigh) THEN
            SystemState := 2; (* Transition to deactivating state *)
        END_IF;
        
    1: (* Activating state - sprinklers turning on *)
        IF SprinklersOn THEN
            SystemState := 3; (* Transition to active state *)
        END_IF;
        
    2: (* Deactivating state - sprinklers turning off *)
        IF NOT SprinklersOn THEN
            SystemState := 0; (* Transition back to idle state *)
        END_IF;
        
    3: (* Active state - sprinklers running *)
        IF SoilMoistureSensor > MoistureThresholdHigh THEN
            SystemState := 2; (* Transition to deactivating state *)
        END_IF;
END_CASE;
END_FUNCTION_BLOCK