ructured-text
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
    state : INT; // THE STATE VARIABLE
    prevState : INT; // THE PREVIOUS STATE VARIABLE
    TargetHumidity : REAL := 50.0; // TARGET HUMIDITY VALUE
    TargetTemperature : REAL := 20.0; // TARGET TEMPERATURE VALUE
    LightThreshold : BOOL := TRUE; // LIGHT THRESHOLD CONDITION
END_VAR

// STATE MACHINE LOGIC
IF state = 0 THEN
    // INITIALIZE STATE
    HVACSystem := FALSE;
    Humidifier := FALSE;
    Dehumidifier := FALSE;
    LightControl := FALSE;

    IF HumiditySensor < TargetHumidity THEN
        state := 1; // Transition to CONTROL_HUMIDITY
    ELSIF HumiditySensor > TargetHumidity THEN
        state := 2; // Transition to CONTROL_TEMPERATURE
    END_IF

ELSIF state = 1 THEN
    // CONTROL_HUMIDITY STATE
    HVACSystem := HVACSystem; // Maintain current HVAC state
    Humidifier := TRUE;
    Dehumidifier := FALSE;
    LightControl := LightControl; // Maintain current light control state

    IF HumiditySensor = TargetHumidity THEN
        state := 0; // Transition to INITIALIZE
    ELSIF LightSensor = FALSE THEN
        state := 3; // Transition to CONTROL_LIGHT
    END_IF

ELSIF state = 2 THEN
    // CONTROL_TEMPERATURE STATE
    HVACSystem := TRUE;
    Humidifier := FALSE;
    Dehumidifier := (HumiditySensor > TargetHumidity);
    LightControl := LightControl; // Maintain current light control state

    IF HumiditySensor = TargetHumidity THEN
        state := 0; // Transition to INITIALIZE
    ELSIF LightSensor = FALSE THEN
        state := 3; // Transition to CONTROL_LIGHT
    END_IF

ELSIF state = 3 THEN
    // CONTROL_LIGHT STATE
    HVACSystem := HVACSystem; // Maintain current HVAC state
    Humidifier := FALSE;
    Dehumidifier := FALSE;
    LightControl := NOT LightSensor AND LightThreshold; // Turn on lights if light sensor is off and threshold is met

    IF LightSensor = TRUE AND HumiditySensor < TargetHumidity THEN
        state := 1; // Transition to CONTROL_HUMIDITY
    ELSIF LightSensor = TRUE AND HumiditySensor > TargetHumidity THEN
        state := 2; // Transition to CONTROL_TEMPERATURE
    END_IF

END_IF

END_FUNCTION_BLOCK
END_ST