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
    state : INT := 0;
    prevState : INT := 0;
END_VAR

CASE state OF
    0: (* STATE_OPERATIONAL *)
        (* Humidity Control - Mutually Exclusive *)
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

        (* Temperature Control *)
        HVACSystem := (TemperatureSensor <> TargetTemperature);

        (* Light Control *)
        LightControl := NOT (LightSensor AND LightThreshold);

        (* State Management *)
        prevState := state;
        state := 0;

END_CASE;

END_FUNCTION_BLOCK
END_ST