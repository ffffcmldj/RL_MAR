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
    tempLight : BOOL;
END_VAR
    tempLight := FALSE;
    IF MotionSensor = TRUE THEN
        tempLight := TRUE;
        EnergyMode := FALSE;
    ELSE
        IF AmbientLight < 50.0 AND EnergySaving = FALSE THEN
            tempLight := TRUE;
        ELSE
            tempLight := FALSE;
        END_IF;
        EnergyMode := EnergySaving;
    END_IF;
    Light := tempLight;
END_FUNCTION_BLOCK