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

// Humidity Control Logic
// Activate humidifier when humidity is below target, dehumidifier when above target
// Both off when exactly at target (mutually exclusive)
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

// Temperature Control Logic
// Activate HVAC when temperature is not equal to target (both above and below)
// Turn off when exactly at target temperature
IF TemperatureSensor <> TargetTemperature THEN
    HVACSystem := TRUE;
ELSE
    HVACSystem := FALSE;
END_IF;

// Lighting Control Logic
// Turn off lights when light sensor detects brightness AND threshold is TRUE
// Otherwise keep lights on
IF LightSensor AND LightThreshold THEN
    LightControl := FALSE;
ELSE
    LightControl := TRUE;
END_IF;

END_FUNCTION_BLOCK