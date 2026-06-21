FUNCTION_BLOCK GreenhouseWateringSystem
VAR_INPUT
    SoilMoistureSensor : REAL;   (* Input for soil moisture level (0-100%) *)
END_VAR

VAR_OUTPUT
    SprinklersOn : BOOL := FALSE; (* Output for controlling sprinklers - on/off *)
END_VAR

VAR
    ResponseDelay : TIME := T#5s;  (* Response delay for the system *)
    TransitionTimer : TON;         (* Timer for managing state transitions *)
    EnableDelay : BOOL := FALSE;   (* Flag to enable delay timing *)
    LastMoistureReading : REAL := 100.0; (* Initialize to ensure sprinklers start off *)
END_VAR

(* Main control logic *)
TransitionTimer(IN:=EnableDelay, PT:=ResponseDelay);

(* Store current moisture reading for next cycle *)
LastMoistureReading := SoilMoistureSensor;

(* Control logic with response delay consideration *)
IF NOT TransitionTimer.Q THEN
    (* Timer is running - wait for delay before changing state *)
    IF TransitionTimer.IN THEN
        (* Continue timing, no state change yet *)
        SprinklersOn := SprinklersOn; (* Maintain current state *)
    ELSE
        (* No transition pending - evaluate conditions *)
        IF (NOT SprinklersOn) AND (SoilMoistureSensor < 30.0) THEN
            (* Condition met to turn sprinklers ON - start delay timer *)
            EnableDelay := TRUE;
        ELSIF SprinklersOn AND (SoilMoistureSensor > 70.0) THEN
            (* Condition met to turn sprinklers OFF - start delay timer *)
            EnableDelay := TRUE;
        ELSE
            (* No transition needed - ensure timer is not running *)
            EnableDelay := FALSE;
            TransitionTimer(IN:=FALSE); (* Reset timer *)
        END_IF;
    END_IF;
ELSE
    (* Timer has completed - execute state transition *)
    EnableDelay := FALSE; (* Reset enable flag *)
    TransitionTimer(IN:=FALSE); (* Reset timer *)
    
    (* Determine which transition to execute based on last evaluation *)
    IF (NOT SprinklersOn) AND (LastMoistureReading < 30.0) THEN
        SprinklersOn := TRUE;
    ELSIF SprinklersOn AND (LastMoistureReading > 70.0) THEN
        SprinklersOn := FALSE;
    END_IF;
END_IF;
END_FUNCTION_BLOCK