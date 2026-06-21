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
        TimerCounter : TIME := T#0s; (* Internal timer counter *)
    END_VAR

    // Initialization: Ensure all control outputs are deactivated when the oven is off
    IF NOT OvenStatus THEN
        HeatingElement := FALSE;
        CoolingElement := FALSE;
        HumidityControl := FALSE;
        DehumidityControl := FALSE;
        BakingTime := T#0s; // Reset baking time
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
        END_IF

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
        END_IF

        // Baking Timer Management
        IF BakingTime > T#0s THEN
            TimerCounter := TimerCounter + T#1s;
            IF TimerCounter >= T#1s THEN
                BakingTime := BakingTime - T#1s;
                TimerCounter := T#0s;
            END_IF
        ELSE
            // Baking complete, turn off all systems
            HeatingElement := FALSE;
            CoolingElement := FALSE;
            HumidityControl := FALSE;
            DehumidityControl := FALSE;
        END_IF
    END_IF
END_FUNCTION_BLOCK