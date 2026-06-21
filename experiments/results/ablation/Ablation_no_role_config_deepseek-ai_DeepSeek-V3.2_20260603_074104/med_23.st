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

(* Main logic *)
IF WeatherForecast = 1 THEN
    (* Rainy condition - always turn pump off *)
    WaterPump := FALSE;
ELSIF WeatherForecast = 0 AND 
      (SoilMoistureSensor1 < SoilMoistureThreshold OR 
       SoilMoistureSensor2 < SoilMoistureThreshold) THEN
    (* Sunny AND at least one sensor below threshold - turn pump on *)
    WaterPump := TRUE;
ELSE
    (* All other conditions - turn pump off *)
    WaterPump := FALSE;
END_IF;

END_FUNCTION_BLOCK