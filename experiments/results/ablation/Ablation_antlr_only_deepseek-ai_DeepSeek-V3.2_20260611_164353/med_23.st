(*
    Smart Irrigation System FUNCTION_BLOCK
    Description: Controls a water pump based on soil moisture sensors and weather forecast.
    Inputs:
        SoilMoistureSensor1, SoilMoistureSensor2 : REAL - Soil moisture readings
        WeatherForecast : INT - 0: Sunny, 1: Rainy, 2: Cloudy
    Output:
        WaterPump : BOOL - TRUE to activate pump
    Internal:
        SoilMoistureThreshold : REAL - Moisture level threshold for irrigation
    Logic:
        1. Rain override: If WeatherForecast = 1, pump is always OFF.
        2. Sunny condition: If WeatherForecast = 0 AND (SoilMoistureSensor1 < Threshold OR SoilMoistureSensor2 < Threshold), pump is ON.
        3. All other conditions: Pump is OFF.
*)

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

(* Main Control Logic *)
(* Priority 1: Rain override - pump must be OFF if forecast is rainy *)
IF WeatherForecast = 1 THEN
    WaterPump := FALSE;
(* Priority 2: Sunny condition with dry soil - pump ON if needed *)
ELSIF WeatherForecast = 0 THEN
    IF (SoilMoistureSensor1 < SoilMoistureThreshold) OR (SoilMoistureSensor2 < SoilMoistureThreshold) THEN
        WaterPump := TRUE;
    ELSE
        WaterPump := FALSE;
    END_IF;
(* Priority 3: All other conditions (cloudy or invalid forecast) - pump OFF *)
ELSE
    WaterPump := FALSE;
END_IF;

END_FUNCTION_BLOCK;