FUNCTION_BLOCK SmartHVACSystem
VAR_INPUT
    TemperatureSensor : REAL;
    HumiditySensor : REAL;
END_VAR
VAR_OUTPUT
    HVACMode : INT := 0;
    HVACFanSpeed : INT := 0;
END_VAR
VAR
    DesiredTemperature : REAL := 24.0;
    DesiredHumidity : REAL := 50.0;
    TemperatureThreshold : REAL := 1.0;
    HumidityThreshold : REAL := 5.0;
    AdjustedHumidity : REAL;
    AdjustedTemperature : REAL;
    NeedsVentilation : BOOL;
    NeedsHeating : BOOL;
    NeedsCooling : BOOL;
END_VAR

    AdjustedHumidity := HumiditySensor;
    IF AdjustedHumidity < 0.0 THEN
        AdjustedHumidity := 0.0;
    ELSIF AdjustedHumidity > 100.0 THEN
        AdjustedHumidity := 100.0;
    END_IF;

    AdjustedTemperature := TemperatureSensor;
    IF AdjustedTemperature < -50.0 THEN
        AdjustedTemperature := -50.0;
    ELSIF AdjustedTemperature > 100.0 THEN
        AdjustedTemperature := 100.0;
    END_IF;

    NeedsVentilation := FALSE;
    NeedsHeating := FALSE;
    NeedsCooling := FALSE;

    IF AdjustedHumidity < (DesiredHumidity - HumidityThreshold) THEN
        NeedsVentilation := TRUE;
    END_IF;

    IF AdjustedTemperature < (DesiredTemperature - TemperatureThreshold) THEN
        NeedsHeating := TRUE;
    END_IF;

    IF AdjustedTemperature > (DesiredTemperature + TemperatureThreshold) THEN
        NeedsCooling := TRUE;
    END_IF;

    HVACMode := 0;
    HVACFanSpeed := 0;

    IF NeedsHeating = TRUE THEN
        HVACMode := 2;
        HVACFanSpeed := 3;
    ELSIF NeedsCooling = TRUE THEN
        HVACMode := 1;
        HVACFanSpeed := 3;
    ELSIF NeedsVentilation = TRUE THEN
        HVACMode := 3;
        HVACFanSpeed := 3;
    END_IF;

END_FUNCTION_BLOCK