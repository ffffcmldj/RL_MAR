FUNCTION_BLOCK GreenhouseWateringSystem
VAR_INPUT
    SoilMoistureSensor : REAL;   (* Input for soil moisture level (0-100%) *)
END_VAR
VAR_OUTPUT
    SprinklersOn : BOOL := FALSE;         (* Output for controlling sprinklers - on/off *)
END_VAR
VAR
    ResponseDelay : TIME := T#5s;  (* Example response delay for the system *)
    LastMoistureReading : REAL;
END_VAR

(* Main control logic *)
IF SoilMoistureSensor < 30.0 THEN
    (* Turn sprinklers ON when moisture is below 30% *)
    SprinklersOn := TRUE;
ELSIF SoilMoistureSensor > 70.0 THEN
    (* Turn sprinklers OFF when moisture is above 70% *)
    SprinklersOn := FALSE;
END_IF;

(* Update last moisture reading for monitoring *)
LastMoistureReading := SoilMoistureSensor;

END_FUNCTION_BLOCK