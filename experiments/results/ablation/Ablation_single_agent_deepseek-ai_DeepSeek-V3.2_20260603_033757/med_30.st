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

// Humidity control logic
IF HumiditySensor < TargetHumidity THEN
    Humidifier := TRUE;
    Dehumidifier := FALSE;
ELSIF HumiditySensor > TargetHumidity THEN
    Humidifier := FALSE;
    Dehumidifier := TRUE;
ELSE
    Humidifier := FALSE;
    Dehumidifier := FALSE;
END_IF;

// Temperature control logic
IF TemperatureSensor <> TargetTemperature THEN
    HVACSystem := TRUE;
ELSE
    HVACSystem := FALSE;
END_IF;

// Lighting control logic
IF LightSensor AND LightThreshold THEN
    LightControl := FALSE;
ELSE
    LightControl := TRUE;
END_IF;

END_FUNCTION_BLOCK