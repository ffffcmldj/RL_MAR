START_ST
FUNCTION_BLOCK OutdoorLEDLightingControl
VAR_INPUT
    AmbientLight : REAL;
    MotionSensor : BOOL;
    EnergySaving : BOOL;
END_VAR
VAR_OUTPUT
    Light : BOOL;
    EnergyMode : BOOL;
END_VAR
VAR
    state : INT := 0; (* STATE 0: PROCESSING (IDLE) *)
    prev_state : INT;
    temp_state : INT;
END_VAR

(* STATE 0: PROCESSING LOGIC *)
IF state = 0 THEN
    (* Motion Detection Override *)
    IF MotionSensor = TRUE THEN
        Light := TRUE;
        EnergyMode := FALSE;
    ELSE (* No Motion Detected *)
        (* Ambient Light and Energy Saving Control *)
        IF (AmbientLight < 50.0) AND (EnergySaving = FALSE) THEN
            Light := TRUE;
        ELSE
            Light := FALSE;
        END_IF;
        (* Energy Mode Status *)
        EnergyMode := EnergySaving;
    END_IF;
END_IF

(* State Management: Keep state constant for this deterministic logic *)
prev_state := state;
temp_state := 0;
state := temp_state;

END_FUNCTION_BLOCK
END_ST