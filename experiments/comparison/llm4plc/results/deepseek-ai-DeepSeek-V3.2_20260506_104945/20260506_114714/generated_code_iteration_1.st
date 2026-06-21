START_REASON
The validation feedback indicates a CODESYS compiler error: "应该用';' 替换'STATE_IDLE'". This is a Chinese error message meaning "should replace 'STATE_IDLE' with ';'". This suggests a syntax issue with the CONST declaration. In CODESYS Structured Text, CONST sections must end with a semicolon (;) after each constant declaration, not a comma. Looking at the original code:

CONST
    STATE_IDLE : INT := 0;
    STATE_CLOSE_COMPLETELY : INT := 1;
    STATE_PARTIALLY_CLOSE : INT := 2;
    STATE_CLOSE_SLIGHTLY : INT := 3;
    STATE_FULLY_OPEN : INT := 4;
END_CONST

The syntax appears correct with semicolons. However, the error message specifically mentions 'STATE_IDLE', which might indicate that the compiler is interpreting something incorrectly. Possibly the issue is that the CONST section is placed inside the FUNCTION_BLOCK but not properly within a VAR_CONSTANT section. In CODESYS, constants should be declared in a VAR_CONSTANT block, not with CONST/END_CONST. The correct syntax is:

VAR_CONSTANT
    STATE_IDLE : INT := 0;
    STATE_CLOSE_COMPLETELY : INT := 1;
    STATE_PARTIALLY_CLOSE : INT := 2;
    STATE_CLOSE_SLIGHTLY : INT := 3;
    STATE_FULLY_OPEN : INT := 4;
END_VAR

Alternatively, if using global constants, they should be defined outside the FUNCTION_BLOCK. But since this is a FUNCTION_BLOCK, internal constants should use VAR_CONSTANT. The original code used CONST/END_CONST, which might not be valid in CODESYS ST. I will change this to VAR_CONSTANT to fix the compiler error.
END_REASON

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
VAR_CONSTANT
    STATE_IDLE : INT := 0;
    STATE_CLOSE_COMPLETELY : INT := 1;
    STATE_PARTIALLY_CLOSE : INT := 2;
    STATE_CLOSE_SLIGHTLY : INT := 3;
    STATE_FULLY_OPEN : INT := 4;
END_VAR

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