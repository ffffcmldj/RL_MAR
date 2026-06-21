START_ST
FUNCTION_BLOCK RetractableRoofControl
VAR_INPUT
    RainSensor : BOOL; (* Input to detect rain *)
    WindSensor : BOOL; (* Input to detect wind *)
    TemperatureSensor : REAL; (* Input to measure temperature *)
END_VAR
VAR_OUTPUT
    RoofMotor : BOOL; (* Output to control the roof motor *)
END_VAR
VAR
END_VAR

    (* Rule 1: If it is raining and windy, then the roof should close completely *)
    IF RainSensor AND WindSensor THEN
        RoofMotor := FALSE;
    (* Rule 2: If it is raining but not windy, then the roof should be partially closed *)
    ELSIF RainSensor AND NOT WindSensor THEN
        RoofMotor := TRUE;
    (* Rule 3: If it is not raining and the temperature is below 20.0°C, then the roof should close slightly *)
    ELSIF NOT RainSensor AND TemperatureSensor < 20.0 THEN
        RoofMotor := TRUE;
    (* Rule 4: If it is not raining and the temperature is 20.0°C or above, then the roof should be fully open *)
    ELSIF NOT RainSensor AND TemperatureSensor >= 20.0 THEN
        RoofMotor := FALSE;
    END_IF;

END_FUNCTION_BLOCK
END_ST