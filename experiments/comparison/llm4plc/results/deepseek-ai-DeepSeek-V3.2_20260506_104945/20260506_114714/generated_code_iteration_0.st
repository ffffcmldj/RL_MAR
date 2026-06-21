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
    state : INT; (* The current state variable *)
    prevState : INT; (* The previous state variable (optional, for debugging or transition logging) *)
END_VAR

(* State definitions *)
CONST
    STATE_IDLE : INT := 0;
    STATE_CLOSE_COMPLETELY : INT := 1;
    STATE_PARTIALLY_CLOSE : INT := 2;
    STATE_CLOSE_SLIGHTLY : INT := 3;
    STATE_FULLY_OPEN : INT := 4;
END_CONST

(* Main state machine logic *)
CASE state OF
    STATE_IDLE:
        (* Output for STATE_IDLE: RoofMotor = FALSE (or maintain previous state, but typically OFF for initialization) *)
        RoofMotor := FALSE;
        
        (* Transitions from STATE_IDLE *)
        IF RainSensor AND WindSensor THEN
            state := STATE_CLOSE_COMPLETELY;
        ELSIF RainSensor AND NOT WindSensor THEN
            state := STATE_PARTIALLY_CLOSE;
        ELSIF NOT RainSensor AND TemperatureSensor < 20.0 THEN
            state := STATE_CLOSE_SLIGHTLY;
        ELSIF NOT RainSensor AND TemperatureSensor >= 20.0 THEN
            state := STATE_FULLY_OPEN;
        END_IF;
        
    STATE_CLOSE_COMPLETELY:
        (* Output for STATE_CLOSE_COMPLETELY: RoofMotor = FALSE (Motor OFF to close completely) *)
        RoofMotor := FALSE;
        
        (* Transitions from STATE_CLOSE_COMPLETELY *)
        IF RainSensor AND NOT WindSensor THEN
            state := STATE_PARTIALLY_CLOSE;
        ELSIF NOT RainSensor AND TemperatureSensor < 20.0 THEN
            state := STATE_CLOSE_SLIGHTLY;
        ELSIF NOT RainSensor AND TemperatureSensor >= 20.0 THEN
            state := STATE_FULLY_OPEN;
        END_IF;
        
    STATE_PARTIALLY_CLOSE:
        (* Output for STATE_PARTIALLY_CLOSE: RoofMotor = TRUE (Motor ON to partially close) *)
        RoofMotor := TRUE;
        
        (* Transitions from STATE_PARTIALLY_CLOSE *)
        IF RainSensor AND WindSensor THEN
            state := STATE_CLOSE_COMPLETELY;
        ELSIF NOT RainSensor AND TemperatureSensor < 20.0 THEN
            state := STATE_CLOSE_SLIGHTLY;
        ELSIF NOT RainSensor AND TemperatureSensor >= 20.0 THEN
            state := STATE_FULLY_OPEN;
        END_IF;
        
    STATE_CLOSE_SLIGHTLY:
        (* Output for STATE_CLOSE_SLIGHTLY: RoofMotor = TRUE (Motor ON to close slightly) *)
        RoofMotor := TRUE;
        
        (* Transitions from STATE_CLOSE_SLIGHTLY *)
        IF RainSensor AND WindSensor THEN
            state := STATE_CLOSE_COMPLETELY;
        ELSIF RainSensor AND NOT WindSensor THEN
            state := STATE_PARTIALLY_CLOSE;
        ELSIF NOT RainSensor AND TemperatureSensor >= 20.0 THEN
            state := STATE_FULLY_OPEN;
        END_IF;
        
    STATE_FULLY_OPEN:
        (* Output for STATE_FULLY_OPEN: RoofMotor = FALSE (Motor OFF to be fully open) *)
        RoofMotor := FALSE;
        
        (* Transitions from STATE_FULLY_OPEN *)
        IF RainSensor AND WindSensor THEN
            state := STATE_CLOSE_COMPLETELY;
        ELSIF RainSensor AND NOT WindSensor THEN
            state := STATE_PARTIALLY_CLOSE;
        ELSIF NOT RainSensor AND TemperatureSensor < 20.0 THEN
            state := STATE_CLOSE_SLIGHTLY;
        END_IF;
        
    ELSE
        (* Default case: reset to IDLE state *)
        state := STATE_IDLE;
        RoofMotor := FALSE;
END_CASE;

(* Optional: Store previous state for debugging or logging *)
prevState := state;

END_FUNCTION_BLOCK
END_ST