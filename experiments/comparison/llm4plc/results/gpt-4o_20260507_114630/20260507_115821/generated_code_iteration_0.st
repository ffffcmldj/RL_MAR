plaintext
START_ST
FUNCTION_BLOCK MuseumClimateControl
VAR_INPUT
    HumiditySensor : REAL;
    TemperatureSensor : REAL;
    LightSensor : BOOL;
END_VAR

VAR_OUTPUT
    HVACSystem : BOOL;
    Humidifier : BOOL;
    Dehumidifier : BOOL;
    LightControl : BOOL;
END_VAR

VAR
    TargetHumidity : REAL := 50.0;
    TargetTemperature : REAL := 20.0;
    LightThreshold : BOOL := TRUE;
    state : INT := 0; // Current state of the FSM
    prevState : INT := -1; // Previous state of the FSM for debugging/tracking
END_VAR

// Main logic of the function block
IF state = 0 THEN
    // STATE 0: IDLE
    HVACSystem := FALSE;
    Humidifier := FALSE;
    Dehumidifier := FALSE;
    LightControl := FALSE;
    
    // Transition to STATE 1
    prevState := state;
    state := 1;

ELSIF state = 1 THEN
    // STATE 1: HUMIDITY CONTROL
    IF HumiditySensor < TargetHumidity THEN
        Humidifier := TRUE;
        Dehumidifier := FALSE;
    ELSIF HumiditySensor > TargetHumidity THEN
        Humidifier := FALSE;
        Dehumidifier := TRUE;
    ELSE
        Humidifier := FALSE;
        Dehumidifier := FALSE;
    END_IF;

    // Transition to STATE 2
    prevState := state;
    state := 2;

ELSIF state = 2 THEN
    // STATE 2: TEMPERATURE CONTROL
    IF (TemperatureSensor < TargetTemperature) OR (TemperatureSensor > TargetTemperature) THEN
        HVACSystem := TRUE;
    ELSE
        HVACSystem := FALSE;
    END_IF;

    // Transition to STATE 3
    prevState := state;
    state := 3;

ELSIF state = 3 THEN
    // STATE 3: LIGHT CONTROL
    IF LightSensor = TRUE AND LightThreshold = TRUE THEN
        LightControl := FALSE;
    ELSE
        LightControl := TRUE;
    END_IF;

    // Transition back to STATE 1
    prevState := state;
    state := 1;

END_IF;

END_FUNCTION_BLOCK
END_ST