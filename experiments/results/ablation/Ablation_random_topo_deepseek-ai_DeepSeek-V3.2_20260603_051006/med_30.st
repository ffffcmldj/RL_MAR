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
Humidifier := FALSE;
Dehumidifier := FALSE;

IF HumiditySensor < TargetHumidity THEN
    Humidifier := TRUE;
ELSIF HumiditySensor > TargetHumidity THEN
    Dehumidifier := TRUE;
END_IF;

// Temperature control logic
IF TemperatureSensor <> TargetTemperature THEN
    HVACSystem := TRUE;
ELSE
    HVACSystem := FALSE;
END_IF;

// Lighting control logic
IF LightSensor AND LightThreshold THEN
    LightControl := FALSE;  // Turn off lights when bright
ELSE
    LightControl := TRUE;   // Turn on lights otherwise
END_IF;

END_FUNCTION_BLOCK