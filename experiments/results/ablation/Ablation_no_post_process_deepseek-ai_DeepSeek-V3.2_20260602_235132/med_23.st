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
    bRainCondition : BOOL;
    bSunnyCondition : BOOL;
    bSoilDryCondition : BOOL;
    bPumpActivateCondition : BOOL;
END_VAR

(* Priority 1: Immediate deactivation for rainy forecast *)
bRainCondition := (WeatherForecast = 1);
IF bRainCondition THEN
    WaterPump := FALSE;
    RETURN;
END_IF;

(* Priority 2: Check activation conditions for sunny weather *)
bSunnyCondition := (WeatherForecast = 0);
bSoilDryCondition := (SoilMoistureSensor1 < SoilMoistureThreshold) OR (SoilMoistureSensor2 < SoilMoistureThreshold);
bPumpActivateCondition := bSunnyCondition AND bSoilDryCondition;

(* Set pump state based on activation conditions *)
IF bPumpActivateCondition THEN
    WaterPump := TRUE;
ELSE
    WaterPump := FALSE;
END_IF;

END_FUNCTION_BLOCK