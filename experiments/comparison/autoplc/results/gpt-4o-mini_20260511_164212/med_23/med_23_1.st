FUNCTION_BLOCK SmartIrrigationSystem
VAR_INPUT
    SoilMoistureSensor1 : REAL;
    SoilMoistureSensor2 : REAL;
    WeatherForecast : INT; (* 0: Sunny, 1: Rainy, 2: Cloudy *)
END_VAR

VAR_OUTPUT
    WaterPump : BOOL;
END_VAR

VAR
    SoilMoistureThreshold : REAL := 30.0;
END_VAR

// Main control logic
IF WeatherForecast = 1 THEN
    // Deactivate pump if weather is rainy
    WaterPump := FALSE;
ELSE
    // Check soil moisture levels
    IF (SoilMoistureSensor1 < SoilMoistureThreshold) OR (SoilMoistureSensor2 < SoilMoistureThreshold) THEN
        IF WeatherForecast = 0 THEN
            // Activate pump if it's sunny and at least one sensor is below threshold
            WaterPump := TRUE;
        ELSE
            // Deactivate pump if weather is not sunny
            WaterPump := FALSE;
        END_IF;
    ELSE
        // Deactivate pump if both sensors are above threshold
        WaterPump := FALSE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK