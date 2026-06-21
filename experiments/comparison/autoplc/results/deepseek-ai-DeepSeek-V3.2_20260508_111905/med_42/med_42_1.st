FUNCTION_BLOCK RetractableRoofControl
VAR_INPUT
    RainSensor : BOOL; (* Input to detect rain *)
    WindSensor : BOOL; (* Input to detect wind *)
    TemperatureSensor : REAL; (* Input to measure temperature *)
END_VAR
VAR_OUTPUT
    RoofMotor : BOOL; (* Output to control the roof motor *)
END_VAR

(* Main control logic *)
IF RainSensor AND WindSensor THEN
    (* Rule 1: If it is raining and windy, close completely *)
    RoofMotor := FALSE;
ELSIF RainSensor AND NOT WindSensor THEN
    (* Rule 2: If it is raining but not windy, partially close *)
    RoofMotor := TRUE;
ELSIF NOT RainSensor AND TemperatureSensor < 20.0 THEN
    (* Rule 3: If not raining and temperature below 20.0°C, close slightly *)
    RoofMotor := TRUE;
ELSE
    (* Rule 4: If not raining and temperature 20.0°C or above, fully open *)
    RoofMotor := FALSE;
END_IF;

END_FUNCTION_BLOCK