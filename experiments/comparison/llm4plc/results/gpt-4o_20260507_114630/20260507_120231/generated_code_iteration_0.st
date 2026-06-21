plaintext
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
    state : INT; (* The current state of the system *)
    prevState : INT; (* The previous state of the system *)
END_VAR

(* Initialization of the system *)
IF state = 0 THEN
    RoofMotor := FALSE; (* Default state, roof is fully open *)
    IF RainSensor AND WindSensor THEN
        state := 1; (* Transition to fully closed state *)
    ELSIF RainSensor AND NOT WindSensor THEN
        state := 2; (* Transition to partially closed state *)
    ELSIF NOT RainSensor AND TemperatureSensor < 20.0 THEN
        state := 3; (* Transition to slightly closed state *)
    ELSIF NOT RainSensor AND TemperatureSensor >= 20.0 THEN
        state := 4; (* Transition to fully open state *)
    END_IF
END_IF

(* Fully closed state *)
IF state = 1 THEN
    RoofMotor := FALSE; (* Roof is fully closed *)
    IF RainSensor AND WindSensor THEN
        state := 1; (* Remain in fully closed state *)
    ELSIF NOT RainSensor AND TemperatureSensor >= 20.0 THEN
        state := 0; (* Return to initial state *)
    END_IF
END_IF

(* Partially closed state *)
IF state = 2 THEN
    RoofMotor := TRUE; (* Roof is partially closed *)
    IF RainSensor AND NOT WindSensor THEN
        state := 2; (* Remain in partially closed state *)
    ELSIF NOT RainSensor AND TemperatureSensor >= 20.0 THEN
        state := 0; (* Return to initial state *)
    END_IF
END_IF

(* Slightly closed state *)
IF state = 3 THEN
    RoofMotor := TRUE; (* Roof is slightly closed *)
    IF NOT RainSensor AND TemperatureSensor < 20.0 THEN
        state := 3; (* Remain in slightly closed state *)
    ELSIF NOT RainSensor AND TemperatureSensor >= 20.0 THEN
        state := 0; (* Return to initial state *)
    END_IF
END_IF

(* Fully open state *)
IF state = 4 THEN
    RoofMotor := FALSE; (* Roof is fully open *)
    IF NOT RainSensor AND TemperatureSensor >= 20.0 THEN
        state := 4; (* Remain in fully open state *)
    ELSIF RainSensor AND WindSensor THEN
        state := 1; (* Transition to fully closed state *)
    END_IF
END_IF

(* Store the previous state for debugging or future use *)
prevState := state;

END_FUNCTION_BLOCK
END_ST