FUNCTION_BLOCK RetractableRoofControl
VAR_INPUT
    RainSensor : BOOL;
    WindSensor : BOOL;
    TemperatureSensor : REAL;
END_VAR
VAR_OUTPUT
    RoofMotor : BOOL;
END_VAR
VAR
    Condition1 : BOOL;
    Condition2 : BOOL;
    Condition3 : BOOL;
END_VAR

Condition1 := RainSensor AND WindSensor;

IF Condition1 THEN
    RoofMotor := FALSE;
ELSIF RainSensor AND NOT WindSensor THEN
    RoofMotor := TRUE;
ELSIF NOT RainSensor AND TemperatureSensor < 20.0 THEN
    RoofMotor := TRUE;
ELSE
    RoofMotor := FALSE;
END_IF;

END_FUNCTION_BLOCK