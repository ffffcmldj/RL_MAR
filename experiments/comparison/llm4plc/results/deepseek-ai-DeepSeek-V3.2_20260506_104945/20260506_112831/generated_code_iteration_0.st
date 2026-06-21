START_ST
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
    state : INT := 0; (* 0: IDLE, 1: PUMP_ACTIVE *)
    prevState : INT := 0;
END_VAR

(* State transition and output logic *)
CASE state OF
    0: (* IDLE state *)
        WaterPump := FALSE;
        IF ( (SoilMoistureSensor1 < SoilMoistureThreshold) OR (SoilMoistureSensor2 < SoilMoistureThreshold) ) AND (WeatherForecast = 0) THEN
            prevState := state;
            state := 1;
        END_IF;
        
    1: (* PUMP_ACTIVE state *)
        WaterPump := TRUE;
        IF (WeatherForecast = 1) OR ( (SoilMoistureSensor1 >= SoilMoistureThreshold) AND (SoilMoistureSensor2 >= SoilMoistureThreshold) ) OR (WeatherForecast <> 0) THEN
            prevState := state;
            state := 0;
        END_IF;
        
    ELSE
        state := 0;
        WaterPump := FALSE;
END_CASE;

END_FUNCTION_BLOCK
END_ST