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

(* Main control logic *)
IF WeatherForecast = 1 THEN
    (* Priority deactivation: pump off if rainy *)
    WaterPump := FALSE;
ELSE
    (* Check activation condition: sunny AND at least one sensor below threshold *)
    IF WeatherForecast = 0 THEN
        IF (SoilMoistureSensor1 < SoilMoistureThreshold) OR (SoilMoistureSensor2 < SoilMoistureThreshold) THEN
            WaterPump := TRUE;
        ELSE
            WaterPump := FALSE;
        END_IF;
    ELSE
        (* Not sunny (cloudy or other) - pump off *)
        WaterPump := FALSE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK