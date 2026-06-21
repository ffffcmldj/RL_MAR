plaintext
START_ST
FUNCTION_BLOCK RetractableRoofControl
VAR_INPUT
    RainSensor : BOOL; (* Rain detection *)
    WindSensor : BOOL; (* Wind detection *)
    TemperatureSensor : REAL; (* Temperature input *)
END_VAR
VAR_OUTPUT
    RoofMotor : BOOL; (* Motor control *)
END_VAR
VAR
    state : INT; (* Current state of the system *)
    prevState : INT; (* Previous state of the system *)
END_VAR

(* State Definitions *)
(* STATE 0: INITIALIZE *)
(* STATE 1: COMBINED RAIN AND WIND DETECTED *)
(* STATE 2: RAIN ONLY DETECTED *)
(* STATE 3: LOW TEMPERATURE DETECTED *)
(* STATE 4: NORMAL CONDITIONS *)

(* Initialize the system and set the default state *)
IF state = 0 THEN
    RoofMotor := FALSE; (* Default state, roof is open *)
    state := 4; (* Transition to default normal conditions state *)
END_IF

(* State Machine Logic *)
CASE state OF
    (* STATE 1: COMBINED RAIN AND WIND DETECTED *)
    1:
        RoofMotor := TRUE; (* Close the roof due to combined rain and wind *)
        IF NOT (RainSensor AND WindSensor) THEN
            (* Transition out of STATE 1 based on conditions *)
            IF RainSensor AND NOT WindSensor THEN
                state := 2; (* Transition to STATE 2: Rain only detected *)
            ELSIF NOT RainSensor AND NOT WindSensor AND TemperatureSensor < 20.0 THEN
                state := 3; (* Transition to STATE 3: Low temperature detected *)
            ELSE
                state := 4; (* Transition to STATE 4: Normal conditions *)
            END_IF
        END_IF

    (* STATE 2: RAIN ONLY DETECTED *)
    2:
        RoofMotor := TRUE; (* Close the roof due to rain only *)
        IF RainSensor AND WindSensor THEN
            state := 1; (* Transition to STATE 1: Combined rain and wind detected *)
        ELSIF NOT RainSensor THEN
            (* Transition out of STATE 2 based on conditions *)
            IF NOT WindSensor AND TemperatureSensor < 20.0 THEN
                state := 3; (* Transition to STATE 3: Low temperature detected *)
            ELSE
                state := 4; (* Transition to STATE 4: Normal conditions *)
            END_IF
        END_IF

    (* STATE 3: LOW TEMPERATURE DETECTED *)
    3:
        RoofMotor := TRUE; (* Close the roof due to low temperature *)
        IF RainSensor AND WindSensor THEN
            state := 1; (* Transition to STATE 1: Combined rain and wind detected *)
        ELSIF RainSensor AND NOT WindSensor THEN
            state := 2; (* Transition to STATE 2: Rain only detected *)
        ELSIF TemperatureSensor >= 20.0 THEN
            state := 4; (* Transition to STATE 4: Normal conditions *)
        END_IF

    (* STATE 4: NORMAL CONDITIONS *)
    4:
        RoofMotor := FALSE; (* Open the roof under normal conditions *)
        IF RainSensor AND WindSensor THEN
            state := 1; (* Transition to STATE 1: Combined rain and wind detected *)
        ELSIF RainSensor AND NOT WindSensor THEN
            state := 2; (* Transition to STATE 2: Rain only detected *)
        ELSIF NOT RainSensor AND NOT WindSensor AND TemperatureSensor < 20.0 THEN
            state := 3; (* Transition to STATE 3: Low temperature detected *)
        END_IF

    (* Default case to handle unexpected states *)
    ELSE
        state := 0; (* Reinitialize the system *)
END_CASE

END_FUNCTION_BLOCK
END_ST