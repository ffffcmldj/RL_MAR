START_ST
FUNCTION_BLOCK OutdoorLEDLightingControl
VAR_INPUT
    AmbientLight : REAL; (* Ambient light sensor input *)
    MotionSensor : BOOL; (* Motion sensor input *)
    EnergySaving : BOOL; (* Energy saving mode switch *)
END_VAR
VAR_OUTPUT
    Light : BOOL; (* LED lighting control output *)
    EnergyMode : BOOL; (* Energy saving mode status output *)
END_VAR
VAR
    state : INT; (* Current state of the FSM (0 = IDLE, 1 = MOTION_OVERRIDE) *)
    prevState : INT; (* Previous state for tracking changes *)
END_VAR

(* State machine initialization *)
IF prevState = 0 THEN
    state := 0;
    prevState := -1;
END_IF;

(* State transitions based on MotionSensor *)
IF MotionSensor THEN
    state := 1; (* Transition to MOTION_OVERRIDE *)
ELSE
    state := 0; (* Transition to IDLE *)
END_IF;

(* State actions *)
CASE state OF
    0: (* IDLE: No motion, evaluate ambient light and energy saving mode *)
        IF (AmbientLight < 50.0) AND (NOT EnergySaving) THEN
            Light := TRUE;
        ELSE
            Light := FALSE;
        END_IF;
        EnergyMode := EnergySaving; (* Reflect input *)

    1: (* MOTION_OVERRIDE: Motion detected, override all other conditions *)
        Light := TRUE; (* Force lights ON *)
        EnergyMode := FALSE; (* Force energy saving mode OFF *)

END_CASE;

(* Update previous state for next scan *)
prevState := state;

END_FUNCTION_BLOCK
END_ST