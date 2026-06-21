ructured-text
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
    state : INT := 0; // STATE 0: INITIALIZE
END_VAR

// STATE MACHINE LOGIC
CASE state OF
    0: // INITIALIZE
        WaterPump := FALSE;
        state := 1; // Transition to STATE 1

    1: // CHECK SOIL MOISTURE AND WEATHER
        IF (SoilMoistureSensor1 < SoilMoistureThreshold OR SoilMoistureSensor2 < SoilMoistureThreshold) AND (WeatherForecast = 0) THEN
            state := 2; // Transition to STATE 2: ACTIVATE WATER PUMP
        ELSIF (WeatherForecast = 1) OR (SoilMoistureSensor1 >= SoilMoistureThreshold AND SoilMoistureSensor2 >= SoilMoistureThreshold) OR (WeatherForecast <> 0) THEN
            state := 3; // Transition to STATE 3: DEACTIVATE WATER PUMP
        END_IF;

    2: // ACTIVATE WATER PUMP
        WaterPump := TRUE;
        state := 1; // Transition back to STATE 1

    3: // DEACTIVATE WATER PUMP
        WaterPump := FALSE;
        state := 1; // Transition back to STATE 1

END_CASE;

END_FUNCTION_BLOCK
END_ST