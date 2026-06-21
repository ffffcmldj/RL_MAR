FUNCTION_BLOCK RetractableRoofControl
VAR_INPUT
    RainSensor : BOOL; (* Input to detect rain *)
    WindSensor : BOOL; (* Input to detect wind *)
    TemperatureSensor : REAL; (* Input to measure temperature *)
END_VAR
VAR_OUTPUT
    RoofMotor : BOOL; (* Output to control the roof motor *)
END_VAR

// Main logic implementation
IF RainSensor AND WindSensor THEN
    RoofMotor := FALSE; (* Close completely when raining and windy *)
ELSIF RainSensor AND NOT WindSensor THEN
    RoofMotor := TRUE; (* Partially close when raining but not windy *)
ELSIF NOT RainSensor AND TemperatureSensor < 20.0 THEN
    RoofMotor := TRUE; (* Close slightly when not raining and temperature below 20°C *)
ELSIF NOT RainSensor AND TemperatureSensor >= 20.0 THEN
    RoofMotor := FALSE; (* Fully open when not raining and temperature 20°C or above *)
ELSE
    RoofMotor := FALSE; (* Default safe state *)
END_IF;

END_FUNCTION_BLOCK