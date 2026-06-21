FUNCTION_BLOCK RetractableRoofControl
    VAR_INPUT
        RainSensor : BOOL; (* Rain detection *)
        WindSensor : BOOL; (* Wind detection *)
        TemperatureSensor : REAL; (* Temperature input *)
    END_VAR

    VAR_OUTPUT
        RoofMotor : BOOL; (* Motor control *)
    END_VAR

    VAR
        TemperatureThreshold : REAL := 20.0;
    END_VAR

    (* Main logic body begins here *)
    IF RainSensor AND WindSensor THEN
        RoofMotor := TRUE;
    ELSIF RainSensor THEN
        RoofMotor := TRUE;
    ELSIF TemperatureSensor < TemperatureThreshold THEN
        RoofMotor := TRUE;
    ELSE
        RoofMotor := FALSE;
    END_IF;

END_FUNCTION_BLOCK;