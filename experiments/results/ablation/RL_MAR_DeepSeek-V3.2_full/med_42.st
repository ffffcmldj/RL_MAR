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
        (* No internal variables needed for this simple logic *)
    END_VAR

    (* Main logic body begins here *)
    IF RainSensor AND WindSensor THEN
        RoofMotor := FALSE;
    ELSIF RainSensor AND NOT WindSensor THEN
        RoofMotor := TRUE;
    ELSIF NOT RainSensor AND TemperatureSensor < 20.0 THEN
        RoofMotor := TRUE;
    ELSIF NOT RainSensor AND TemperatureSensor >= 20.0 THEN
        RoofMotor := FALSE;
    END_IF;

END_FUNCTION_BLOCK;