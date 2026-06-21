FUNCTION_BLOCK WindTurbineControl
VAR_INPUT
    WindSpeedSensor : REAL;
    GeneratorSpeedSensor : REAL;
END_VAR
VAR_OUTPUT
    BladePitch : INT;
    GeneratorSpeed : REAL;
END_VAR
VAR
    isLowWind : BOOLEAN;
    isModerateWind : BOOLEAN;
END_VAR

isLowWind := (WindSpeedSensor <= 3.0);

IF isLowWind THEN
    BladePitch := -5;
    GeneratorSpeed := 500.0;
ELSIF (WindSpeedSensor > 3.0) AND (WindSpeedSensor <= 5.0) THEN
    isModerateWind := TRUE;
    BladePitch := 0;
    GeneratorSpeed := 800.0;
ELSE
    BladePitch := 5;
    GeneratorSpeed := 1000.0;
END_IF

END_FUNCTION_BLOCK