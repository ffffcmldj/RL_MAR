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

IF WeatherForecast = 1 THEN
    WaterPump := FALSE;
ELSIF WeatherForecast = 0 THEN
    IF (SoilMoistureSensor1 < SoilMoistureThreshold) OR (SoilMoistureSensor2 < SoilMoistureThreshold) THEN
        WaterPump := TRUE;
    ELSE
        WaterPump := FALSE;
    END_IF;
ELSE
    WaterPump := FALSE;
END_IF;

END_FUNCTION_BLOCK;