FUNCTION_BLOCK GreenhouseWateringSystem
VAR
    SoilMoistureSensor : REAL;   // Input for soil moisture level (0-100%)
    SprinklersOn : BOOL := FALSE; // Output for controlling sprinklers - on/off
    ResponseDelay : TIME := T#5s; // Example response delay for the system
    LastMoistureReading : REAL;   // To store the last moisture reading
    TimerStart : TIME;            // To store the time when the timer started
    TimerActive : BOOL := FALSE;  // To indicate if the timer is active
END_VAR

VAR
    CurrentTime : TIME;           // Current time for delay calculation
    TimeElapsed : TIME;           // Time elapsed since the timer started
END_VAR

// Initialization
IF NOT TimerActive THEN
    TimerStart := TIME(); // Initialize the timer start time
END_IF

// Monitoring Soil Moisture
LastMoistureReading := SoilMoistureSensor;

// Control Logic
IF NOT SprinklersOn THEN
    // Check if soil moisture is below 30% to turn on sprinklers
    IF LastMoistureReading < 30.0 THEN
        TimerActive := TRUE;
        CurrentTime := TIME();
        TimeElapsed := CurrentTime - TimerStart;
        
        // Check if the response delay has passed
        IF TimeElapsed >= ResponseDelay THEN
            SprinklersOn := TRUE;
            TimerActive := FALSE; // Reset timer
        END_IF
    ELSE
        TimerActive := FALSE; // Reset timer if condition not met
    END_IF
ELSE
    // Check if soil moisture is above 70% to turn off sprinklers
    IF LastMoistureReading > 70.0 THEN
        TimerActive := TRUE;
        CurrentTime := TIME();
        TimeElapsed := CurrentTime - TimerStart;
        
        // Check if the response delay has passed
        IF TimeElapsed >= ResponseDelay THEN
            SprinklersOn := FALSE;
            TimerActive := FALSE; // Reset timer
        END_IF
    ELSE
        TimerActive := FALSE; // Reset timer if condition not met
    END_IF
END_IF

END_FUNCTION_BLOCK