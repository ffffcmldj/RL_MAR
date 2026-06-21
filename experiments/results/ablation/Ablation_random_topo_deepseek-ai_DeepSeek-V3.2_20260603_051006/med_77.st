FUNCTION_BLOCK OutdoorLEDLightingControl
VAR_INPUT
    AmbientLight : REAL;    (* Ambient light sensor input in Lux *)
    MotionSensor : BOOL;    (* Motion sensor input (TRUE = motion detected) *)
    EnergySaving : BOOL;    (* Energy saving mode switch (TRUE = energy saving ON) *)
END_VAR

VAR_OUTPUT
    Light : BOOL;           (* LED lighting control output (TRUE = lights ON) *)
    EnergyMode : BOOL;      (* Energy saving mode status output *)
END_VAR

(* Main control logic *)
IF MotionSensor THEN
    (* Motion Detection Override: Lights ON, EnergyMode reflects input *)
    Light := TRUE;
ELSE
    (* No motion detected - Ambient Light and Energy Saving Control *)
    IF (AmbientLight < 50.0) AND NOT EnergySaving THEN
        Light := TRUE;
    ELSE
        Light := FALSE;
    END_IF;
END_IF;

(* Energy Mode Status always reflects EnergySaving input *)
EnergyMode := EnergySaving;

END_FUNCTION_BLOCK