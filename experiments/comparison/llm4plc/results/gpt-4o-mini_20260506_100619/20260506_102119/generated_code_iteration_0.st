ructured-text
START_ST
FUNCTION_BLOCK RetractableRoofControl
VAR_INPUT
    RainSensor : BOOL; (* Input to detect rain *)
    WindSensor : BOOL; (* Input to detect wind *)
    TemperatureSensor : REAL; (* Input to measure temperature *)
END_VAR
VAR_OUTPUT
    RoofMotor : BOOL; (* Output to control the roof motor *)
END_VAR
VAR
    state : INT; (* Current state variable *)
    prevState : INT; (* Previous state variable *)
END_VAR

(* State definitions *)
STATE_0 : INT := 0; (* RAINING AND WINDY *)
STATE_1 : INT := 1; (* RAINING BUT NOT WINDY *)
STATE_2 : INT := 2; (* NOT RAINING AND TEMPERATURE < 20°C *)
STATE_3 : INT := 3; (* NOT RAINING AND TEMPERATURE >= 20°C *)

(* State machine logic *)
IF RainSensor AND WindSensor THEN
    RoofMotor := FALSE; (* Roof should close completely *)
    state := STATE_0; 
ELSIF RainSensor AND NOT WindSensor THEN
    RoofMotor := TRUE; (* Roof should be partially closed *)
    state := STATE_1; 
ELSIF NOT RainSensor AND TemperatureSensor < 20.0 THEN
    RoofMotor := TRUE; (* Roof should close slightly *)
    state := STATE_2; 
ELSIF NOT RainSensor AND TemperatureSensor >= 20.0 THEN
    RoofMotor := FALSE; (* Roof should be fully open *)
    state := STATE_3; 
END_IF;

(* State transitions *)
CASE state OF
    STATE_0:
        IF NOT RainSensor AND NOT WindSensor THEN
            state := STATE_3; (* Transition to fully open state *)
        ELSIF NOT WindSensor THEN
            state := STATE_1; (* Transition to partially closed state *)
        END_IF;
    STATE_1:
        IF RainSensor AND WindSensor THEN
            state := STATE_0; (* Transition to completely closed state *)
        ELSIF NOT RainSensor AND TemperatureSensor < 20.0 THEN
            state := STATE_2; (* Transition to slightly closed state *)
        ELSIF NOT RainSensor AND TemperatureSensor >= 20.0 THEN
            state := STATE_3; (* Transition to fully open state *)
        END_IF;
    STATE_2:
        IF NOT RainSensor AND TemperatureSensor >= 20.0 THEN
            state := STATE_3; (* Transition to fully open state *)
        ELSIF RainSensor AND WindSensor THEN
            state := STATE_0; (* Transition to completely closed state *)
        END_IF;
    STATE_3:
        IF RainSensor AND WindSensor THEN
            state := STATE_0; (* Transition to completely closed state *)
        ELSIF RainSensor AND NOT WindSensor THEN
            state := STATE_1; (* Transition to partially closed state *)
        ELSIF NOT RainSensor AND TemperatureSensor < 20.0 THEN
            state := STATE_2; (* Transition to slightly closed state *)
        END_IF;
END_CASE;

END_FUNCTION_BLOCK
END_ST