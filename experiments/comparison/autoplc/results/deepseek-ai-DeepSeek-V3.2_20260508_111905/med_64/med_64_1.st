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
    
    // Internal variables for timer management
    LastTickTime : TIME := T#0s; (* Last time the timer was decremented *)
    CurrentTime : TIME := T#0s; (* Current system time *)
    TimeElapsed : TIME := T#0s; (* Time elapsed since last decrement *)
    OneSecond : TIME := T#1s; (* Constant for one second *)
    TimerActive : BOOL := FALSE; (* Flag to track if timer is active *)
    
    // Internal variables for control calculations
    TempLowerBound : REAL := 0.0; (* Lower temperature bound *)
    TempUpperBound : REAL := 0.0; (* Upper temperature bound *)
    HumidLowerBound : REAL := 0.0; (* Lower humidity bound *)
    HumidUpperBound : REAL := 0.0; (* Upper humidity bound *)
END_VAR

// Main execution logic
IF NOT OvenStatus THEN
    // Oven is OFF - deactivate all control outputs
    HeatingElement := FALSE;
    CoolingElement := FALSE;
    HumidityControl := FALSE;
    DehumidityControl := FALSE;
    
    // Reset timer flag when oven is off
    TimerActive := FALSE;
    LastTickTime := T#0s;
ELSE
    // Oven is ON - perform control logic
    
    // Calculate control bounds
    TempLowerBound := OvenTemperature - HeatingThreshold;
    TempUpperBound := OvenTemperature + HeatingThreshold;
    HumidLowerBound := OvenHumidity - HumidityThreshold;
    HumidUpperBound := OvenHumidity + HumidityThreshold;
    
    // Temperature control logic
    IF TemperatureSensor < TempLowerBound THEN
        // Temperature is too low - activate heating
        HeatingElement := TRUE;
        CoolingElement := FALSE;
    ELSIF TemperatureSensor > TempUpperBound THEN
        // Temperature is too high - activate cooling
        HeatingElement := FALSE;
        CoolingElement := TRUE;
    ELSE
        // Temperature is within acceptable range
        HeatingElement := FALSE;
        CoolingElement := FALSE;
    END_IF;
    
    // Humidity control logic
    IF HumiditySensor < HumidLowerBound THEN
        // Humidity is too low - activate humidification
        HumidityControl := TRUE;
        DehumidityControl := FALSE;
    ELSIF HumiditySensor > HumidUpperBound THEN
        // Humidity is too high - activate dehumidification
        HumidityControl := FALSE;
        DehumidityControl := TRUE;
    ELSE
        // Humidity is within acceptable range
        HumidityControl := FALSE;
        DehumidityControl := FALSE;
    END_IF;
    
    // Timer management - decrement baking timer at one-second intervals
    CurrentTime := TIME(); // Get current system time
    
    IF NOT TimerActive THEN
        // Initialize timer on first execution when oven is on
        LastTickTime := CurrentTime;
        TimerActive := TRUE;
    END_IF;
    
    // Calculate time elapsed since last decrement
    TimeElapsed := CurrentTime - LastTickTime;
    
    // Check if one second has elapsed
    IF TimeElapsed >= OneSecond THEN
        // Decrement baking timer by one second
        IF BakingTime > T#0s THEN
            BakingTime := BakingTime - OneSecond;
            LastTickTime := CurrentTime; // Update last tick time
            
            // Check if timer has reached zero
            IF BakingTime <= T#0s THEN
                // Baking complete - turn off oven
                OvenStatus := FALSE;
                BakingTime := T#0s;
                
                // Deactivate all control outputs
                HeatingElement := FALSE;
                CoolingElement := FALSE;
                HumidityControl := FALSE;
                DehumidityControl := FALSE;
                
                // Reset timer flag
                TimerActive := FALSE;
            END_IF;
        END_IF;
    END_IF;
END_IF;
END_FUNCTION_BLOCK