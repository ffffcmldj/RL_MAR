FUNCTION_BLOCK BakeryOvenControl
    VAR_INPUT
        TemperatureSensor : REAL; (* Sensor input for oven temperature *)
        HumiditySensor : REAL; (* Sensor input for oven humidity *)
    END_VAR

    VAR_OUTPUT
        HeatingElement : BOOL; (* Control signal for heating element *)
        CoolingElement : BOOL; (* Control signal for cooling element *)
        HumidityControl : BOOL; (* Control signal for humidity system *)
        DehumidityControl : BOOL; (* Control signal for dehumidification *)
    END_VAR

    VAR
        OvenTemperature : REAL := 0.0; (* Current oven temperature setpoint *)
        OvenHumidity : REAL := 0.0; (* Current oven humidity setpoint *)
        BakingTime : TIME := T#0s; (* Baking time setpoint *)
        OvenStatus : BOOL := FALSE; (* Oven status: TRUE=On, FALSE=Off *)
        HeatingThreshold : REAL := 2.0; (* Temperature control threshold *)
        HumidityThreshold : REAL := 5.0; (* Humidity control threshold *)
        Timer : TIME := T#0s; (* Timer for baking countdown *)
    END_VAR

    // Initialization
    IF NOT OvenStatus THEN
        HeatingElement := FALSE;
        CoolingElement := FALSE;
        HumidityControl := FALSE;
        DehumidityControl := FALSE;
        OvenTemperature := 200.0; // Example setpoint for temperature
        OvenHumidity := 50.0; // Example setpoint for humidity
        BakingTime := T#60s; // Example baking time
    ELSE
        // Temperature Control Logic
        IF TemperatureSensor < (OvenTemperature - HeatingThreshold) THEN
            HeatingElement := TRUE;
            CoolingElement := FALSE;
        ELSIF TemperatureSensor > (OvenTemperature + HeatingThreshold) THEN
            HeatingElement := FALSE;
            CoolingElement := TRUE;
        ELSE
            HeatingElement := FALSE;
            CoolingElement := FALSE;
        END_IF;

        // Humidity Control Logic
        IF HumiditySensor < (OvenHumidity - HumidityThreshold) THEN
            HumidityControl := TRUE;
            DehumidityControl := FALSE;
        ELSIF HumiditySensor > (OvenHumidity + HumidityThreshold) THEN
            HumidityControl := FALSE;
            DehumidityControl := TRUE;
        ELSE
            HumidityControl := FALSE;
            DehumidityControl := FALSE;
        END_IF;

        // Baking Timer Logic
        IF BakingTime > T#0s THEN
            Timer := Timer + T#1s; // Increment timer by 1 second
            BakingTime := BakingTime - T#1s; // Decrement baking time
        END_IF;

        // Check if baking is complete
        IF BakingTime <= T#0s THEN
            HeatingElement := FALSE;
            CoolingElement := FALSE;
            HumidityControl := FALSE;
            DehumidityControl := FALSE;
            OvenStatus := FALSE; // Turn off the oven
        END_IF;
    END_IF;
END_FUNCTION_BLOCK