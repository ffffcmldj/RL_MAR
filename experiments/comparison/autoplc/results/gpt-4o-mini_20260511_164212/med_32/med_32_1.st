FUNCTION_BLOCK GreenhouseWateringSystem
VAR
    SoilMoistureSensor : REAL;   (* Input for soil moisture level (0-100%) *)
    SprinklersOn : BOOL := FALSE;         (* Output for controlling sprinklers - on/off *)
    ResponseDelay : TIME := T#5s;  (* Example response delay for the system *)
    LastMoistureReading : REAL;
    CurrentTime : TIME;            (* Variable to track current time *)
    DelayStartTime : TIME;         (* Variable to track when the delay starts *)
    DelayActive : BOOL := FALSE;   (* Flag to indicate if delay is active *)
END_VAR

(* Main control logic *)
IF SoilMoistureSensor < 30.0 THEN
    (* Check if sprinklers are off and activate them *)
    IF NOT SprinklersOn THEN
        SprinklersOn := TRUE;      (* Activate sprinklers *)
        DelayStartTime := CurrentTime;  (* Start delay timer *)
        DelayActive := TRUE;       (* Set delay active flag *)
    END_IF
ELSIF SoilMoistureSensor > 70.0 THEN
    (* Check if sprinklers are on and deactivate them *)
    IF SprinklersOn THEN
        SprinklersOn := FALSE;     (* Deactivate sprinklers *)
        DelayStartTime := CurrentTime;  (* Start delay timer *)
        DelayActive := TRUE;       (* Set delay active flag *)
    END_IF
END_IF

(* Handle response delay *)
IF DelayActive THEN
    (* Check if the response delay time has elapsed *)
    IF (CurrentTime - DelayStartTime) >= ResponseDelay THEN
        DelayActive := FALSE;      (* Reset delay active flag *)
    END_IF
END_IF

(* Update last moisture reading *)
LastMoistureReading := SoilMoistureSensor;  (* Maintain moisture parameters *)
END_FUNCTION_BLOCK