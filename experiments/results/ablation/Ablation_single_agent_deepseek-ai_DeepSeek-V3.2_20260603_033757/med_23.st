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

(* Main irrigation logic *)
IF WeatherForecast = 1 THEN
    (* Deactivate pump if rain is forecast *)
    WaterPump := FALSE;
ELSIF WeatherForecast = 0 THEN
    (* Activate pump only if sunny AND at least one sensor below threshold *)
    WaterPump := (SoilMoistureSensor1 < SoilMoistureThreshold) OR 
                 (SoilMoistureSensor2 < SoilMoistureThreshold);
ELSE
    (* Keep pump off for cloudy or any other weather condition *)
    WaterPump := FALSE;
END_IF;

END_FUNCTION_BLOCK