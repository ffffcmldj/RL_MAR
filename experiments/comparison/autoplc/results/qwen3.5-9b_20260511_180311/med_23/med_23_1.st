FUNCTION_BLOCK SmartIrrigationSystem
VAR_INPUT
    SoilMoistureSensor1 : REAL;
    SoilMoistureSensor2 : REAL;
    WeatherForecast : INT;
END_VAR
VAR_OUTPUT
    WaterPump : BOOL;
END_VAR
VAR
    SoilMoistureThreshold : REAL := 30.0;
    IsRainy : BOOL;
    IsSunny : BOOL;
    IsMoistureLow : BOOL;
END_VAR

IsRainy := (WeatherForecast = 1);
IsSunny := (WeatherForecast = 0);
IsMoistureLow := (SoilMoistureSensor1 < SoilMoistureThreshold) OR (SoilMoistureSensor2 < SoilMoistureThreshold);

IF IsRainy THEN
    WaterPump := FALSE;
ELSIF IsSunny AND IsMoistureLow THEN
    WaterPump := TRUE;
ELSE
    WaterPump := FALSE;
END_IF

END_FUNCTION_BLOCK