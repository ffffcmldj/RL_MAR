FUNCTION_BLOCK OutdoorLEDLightingControl
VAR_INPUT
    AmbientLight : REAL;    (* Ambient light sensor input in Lux *)
    MotionSensor : BOOL;    (* Motion sensor input *)
    EnergySaving : BOOL;    (* Energy saving mode switch *)
END_VAR

VAR_OUTPUT
    Light : BOOL;           (* LED lighting control output *)
    EnergyMode : BOOL;      (* Energy saving mode status output *)
END_VAR

(* Main control logic *)
IF MotionSensor THEN
    (* Motion Detection Override *)
    Light := TRUE;
    EnergyMode := FALSE;    (* Override energy-saving mode *)
ELSE
    (* No motion detected *)
    EnergyMode := EnergySaving;    (* Reflect energy saving input *)
    
    (* Ambient Light and Energy Saving Control *)
    IF (AmbientLight < 50.0) AND (NOT EnergySaving) THEN
        Light := TRUE;
    ELSE
        Light := FALSE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK