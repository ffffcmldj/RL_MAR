FUNCTION_BLOCK MuseumClimateControl
VAR_INPUT
    HumiditySensor : REAL;
    TemperatureSensor : REAL;
    LightSensor : BOOL;
END_VAR
VAR_OUTPUT
    HVACSystem : BOOL;
    Humidifier : BOOL;
    Dehumidifier : BOOL;
    LightControl : BOOL;
END_VAR
VAR
    TargetHumidity : REAL := 50.0;
    TargetTemperature : REAL := 20.0;
    LightThreshold : BOOL := TRUE;
END_VAR

IF HumiditySensor < TargetHumidity THEN
    Humidifier := TRUE;
    Dehumidifier := FALSE;
ELSIF HumiditySensor > TargetHumidity THEN
    Dehumidifier := TRUE;
    Humidifier := FALSE;
ELSE
    Humidifier := FALSE;
    Dehumidifier := FALSE;
END_IF;

IF TemperatureSensor <> TargetTemperature THEN
    HVACSystem := TRUE;
ELSE
    HVACSystem := FALSE;
END_IF;

IF LightSensor = TRUE AND LightThreshold = TRUE THEN
    LightControl := FALSE;
ELSE
    LightControl := TRUE;
END_IF;

END_FUNCTION_BLOCK