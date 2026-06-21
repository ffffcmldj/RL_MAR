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
    state : INT; (* Current state variable (0 or 1) *)
    prevState : INT; (* Previous state variable for tracking changes *)
END_VAR

(* State 0: INITIALIZE *)
IF state = 0 THEN
    (* Set initial conditions and prepare for normal operation *)
    RoofMotor := FALSE; (* Open roof as default safe position *)
    (* Always transition to STATE 1 on the next scan cycle *)
    state := 1;
END_IF;

(* State 1: EVALUATE CONDITIONS *)
IF state = 1 THEN
    (* Continuously monitor sensors and apply priority logic *)
    (* Evaluate conditions in exact priority order *)
    IF (RainSensor AND WindSensor) THEN
        (* Combined Rain and Wind (Highest Priority) *)
        RoofMotor := TRUE; (* Close roof *)
    ELSIF RainSensor THEN
        (* Rain Only *)
        RoofMotor := TRUE; (* Close roof *)
    ELSIF TemperatureSensor < 20.0 THEN
        (* Low Temperature *)
        RoofMotor := TRUE; (* Close roof *)
    ELSE
        (* Normal Conditions *)
        RoofMotor := FALSE; (* Open roof *)
    END_IF;
    (* Remain in STATE 1 for continuous monitoring *)
    state := 1;
END_IF;

(* Track previous state for debugging or future extensions *)
prevState := state;
END_FUNCTION_BLOCK
END_ST