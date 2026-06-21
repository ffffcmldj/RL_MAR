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
    Tolerance : REAL := 0.1;  // Tolerance for floating-point comparisons
END_VAR

    // Humidity control logic
    IF HumiditySensor < (TargetHumidity - Tolerance) THEN
        Humidifier := TRUE;
        Dehumidifier := FALSE;
    ELSIF HumiditySensor > (TargetHumidity + Tolerance) THEN
        Humidifier := FALSE;
        Dehumidifier := TRUE;
    ELSE
        Humidifier := FALSE;
        Dehumidifier := FALSE;
    END_IF;
    
    // Temperature control logic
    IF (TemperatureSensor < (TargetTemperature - Tolerance)) OR (TemperatureSensor > (TargetTemperature + Tolerance)) THEN
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