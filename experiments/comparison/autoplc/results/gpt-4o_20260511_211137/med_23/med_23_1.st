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

VAR
    IsSoilMoistureLow : BOOL;
END_VAR

// Main logic to control the water pump
IF WeatherForecast = 1 THEN
    // Deactivate pump if weather is rainy
    WaterPump := FALSE;
ELSE
    // Check if either soil moisture sensor reads below the threshold
    IsSoilMoistureLow := (SoilMoistureSensor1 < SoilMoistureThreshold) OR (SoilMoistureSensor2 < SoilMoistureThreshold);
    
    IF IsSoilMoistureLow AND (WeatherForecast = 0) THEN
        // Activate pump if soil moisture is low and weather is sunny
        WaterPump := TRUE;
    ELSE
        // Deactivate pump if soil moisture is not low or weather is not sunny
        WaterPump := FALSE;
    END_IF
END_IF

END_FUNCTION_BLOCK