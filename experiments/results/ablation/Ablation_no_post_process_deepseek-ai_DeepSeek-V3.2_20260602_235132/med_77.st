(*
    FUNCTION_BLOCK: OutdoorLEDLightingControl
    DESCRIPTION: Controls a modular outdoor LED lighting system based on ambient light, motion detection, and an energy-saving setting.
    LOGIC PRIORITY:
        1. Motion Detection Override: Lights ON if motion is detected.
        2. Ambient/Energy-Saving Logic: Lights ON only if ambient light < 50.0 AND energy-saving is OFF (when no motion is detected).
    OUTPUTS:
        Light: Controls the LED lights (TRUE = ON).
        EnergyMode: Reflects the current state of the EnergySaving input.
*)

FUNCTION_BLOCK OutdoorLEDLightingControl
VAR_INPUT
    AmbientLight : REAL;   (* Ambient light intensity in Lux *)
    MotionSensor : BOOL;   (* TRUE = Motion detected *)
    EnergySaving : BOOL;   (* TRUE = Energy saving mode is ON *)
END_VAR

VAR_OUTPUT
    Light      : BOOL;     (* Control output for the LED lights *)
    EnergyMode : BOOL;     (* Current energy-saving mode status *)
END_VAR

VAR
    // No internal variables required for this logic
END_VAR

// Main Control Logic
// 1. Energy Mode Status: Always reflect the input state.
EnergyMode := EnergySaving;

// 2. Light Control Logic
IF MotionSensor THEN
    // Motion Detection Override: Lights ON regardless of other conditions.
    Light := TRUE;
ELSE
    // No motion detected: Evaluate ambient light and energy-saving setting.
    IF (AmbientLight < 50.0) AND (NOT EnergySaving) THEN
        Light := TRUE;
    ELSE
        Light := FALSE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK