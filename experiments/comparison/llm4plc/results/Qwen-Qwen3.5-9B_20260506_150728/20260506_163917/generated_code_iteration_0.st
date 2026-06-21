START_ST
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

BEGIN
    (* STATE 0: HUMIDITY_EVALUATION *)
    (* Logic: Activate humidifier if < 50.0, dehumidifier if > 50.0, both off if = 50.0 *)
    (* Safety Check: Mutually exclusive *)
    IF HumiditySensor < TargetHumidity THEN
        Humidifier := TRUE;
        Dehumidifier := FALSE;
    ELSIF HumiditySensor > TargetHumidity THEN
        Humidifier := FALSE;
        Dehumidifier := TRUE;
    ELSE (* HumiditySensor = TargetHumidity *)
        Humidifier := FALSE;
        Dehumidifier := FALSE;
    END_IF;

    (* STATE 1: TEMPERATURE_EVALUATION *)
    (* Logic: Activate HVAC if != 20.0, deactivate if == 20.0 *)
    IF TemperatureSensor <> TargetTemperature THEN
        HVACSystem := TRUE;
    ELSE
        HVACSystem := FALSE;
    END_IF;

    (* STATE 2: LIGHT_EVALUATION *)
    (* Logic: Turn OFF lights if LightSensor=TRUE AND LightThreshold=TRUE, otherwise ON *)
    IF LightSensor = TRUE AND LightThreshold = TRUE THEN
        LightControl := FALSE;
    ELSE
        LightControl := TRUE;
    END_IF;

END_FUNCTION_BLOCK
END_ST