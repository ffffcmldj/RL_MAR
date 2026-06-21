FUNCTION_BLOCK OutdoorLEDLightingControl
VAR_INPUT
    AmbientLight : REAL;    (* Ambient light sensor input in Lux *)
    MotionSensor : BOOL;    (* Motion sensor input (TRUE = Motion detected) *)
    EnergySaving : BOOL;    (* Energy-saving mode switch (TRUE = Energy saving ON) *)
END_VAR

VAR_OUTPUT
    Light : BOOL;           (* LED lighting control output (TRUE = Lights ON) *)
    EnergyMode : BOOL;      (* Energy-saving mode status output *)
END_VAR

VAR
    (* No internal variables required for this implementation *)
END_VAR

BEGIN
    (* Energy Mode Status: Always reflect the EnergySaving input *)
    EnergyMode := EnergySaving;
    
    (* Motion Detection Override - Highest Priority *)
    IF MotionSensor THEN
        Light := TRUE;      (* Override: Lights ON when motion detected *)
    ELSE
        (* Ambient Light and Energy Saving Control (when no motion detected) *)
        IF (AmbientLight < 50.0) AND (NOT EnergySaving) THEN
            Light := TRUE;  (* Lights ON: Low ambient light AND energy-saving OFF *)
        ELSE
            Light := FALSE; (* Lights OFF: Either sufficient light OR energy-saving ON *)
        END_IF;
    END_IF;
END_FUNCTION_BLOCK