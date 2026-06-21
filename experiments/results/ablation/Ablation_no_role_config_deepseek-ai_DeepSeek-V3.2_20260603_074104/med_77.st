FUNCTION_BLOCK OutdoorLEDLightingControl
VAR_INPUT
    AmbientLight : REAL;    (* Ambient light sensor input in Lux *)
    MotionSensor : BOOL;    (* Motion sensor input (TRUE = motion detected) *)
    EnergySaving : BOOL;    (* Energy saving mode input (TRUE = energy saving ON) *)
END_VAR

VAR_OUTPUT
    Light : BOOL;           (* LED lighting control output (TRUE = lights ON) *)
    EnergyMode : BOOL;      (* Energy saving mode status output *)
END_VAR

(* Main control logic *)
IF MotionSensor THEN
    (* Motion detection override *)
    Light := TRUE;
    EnergyMode := FALSE;
ELSE
    (* No motion detected - apply ambient light and energy saving logic *)
    IF (AmbientLight < 50.0) AND (NOT EnergySaving) THEN
        Light := TRUE;
    ELSE
        Light := FALSE;
    END_IF;
    
    (* Energy mode always reflects the EnergySaving input *)
    EnergyMode := EnergySaving;
END_IF;

END_FUNCTION_BLOCK