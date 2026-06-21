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
    (* No internal variables required for this logic *)
END_VAR

BEGIN
    IF RainSensor AND WindSensor THEN
        RoofMotor := FALSE; (* Close completely *)
    ELSIF RainSensor AND NOT WindSensor THEN
        RoofMotor := TRUE; (* Partially closed *)
    ELSIF NOT RainSensor AND TemperatureSensor < 20.0 THEN
        RoofMotor := TRUE; (* Close slightly *)
    ELSIF NOT RainSensor AND TemperatureSensor >= 20.0 THEN
        RoofMotor := FALSE; (* Fully open *)
    ELSE
        RoofMotor := FALSE; (* Default state - safety fallback *)
    END_IF;
END_FUNCTION_BLOCK