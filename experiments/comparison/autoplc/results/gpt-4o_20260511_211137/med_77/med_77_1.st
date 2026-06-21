FUNCTION_BLOCK OutdoorLEDLightingControl
    VAR_INPUT
        AmbientLight : REAL; (* Input from an ambient light sensor *)
        MotionSensor : BOOL; (* Input from a motion sensor *)
        EnergySaving : BOOL; (* Input to enable/disable energy-saving mode *)
    END_VAR
    VAR_OUTPUT
        Light : BOOL; (* Control output for the LED lights *)
        EnergyMode : BOOL; (* Output indicating the current energy-saving mode status *)
    END_VAR

    VAR
        (* No additional internal variables needed for this logic *)
    END_VAR

    (* Control Logic Implementation *)
    (* Motion Detection Override *)
    IF MotionSensor THEN
        Light := TRUE; (* Turn lights on if motion is detected *)
        EnergyMode := FALSE; (* Deactivate energy-saving mode *)
    ELSE
        (* Ambient Light and Energy Saving Control when no motion is detected *)
        IF (AmbientLight < 50.0) AND NOT EnergySaving THEN
            Light := TRUE; (* Turn lights on if ambient light is low and energy-saving is off *)
        ELSE
            Light := FALSE; (* Turn lights off if ambient light is sufficient or energy-saving is on *)
        END_IF;
        
        (* Energy Mode Status *)
        EnergyMode := EnergySaving; (* Reflect the current state of the EnergySaving input *)
    END_IF;
END_FUNCTION_BLOCK