plaintext
START_ST
FUNCTION_BLOCK OutdoorLEDLightingControl
VAR_INPUT
    AmbientLight : REAL; (* Input from ambient light sensor *)
    MotionSensor : BOOL; (* Input from motion sensor *)
    EnergySaving : BOOL; (* Input to enable/disable energy-saving mode *)
END_VAR
VAR_OUTPUT
    Light : BOOL; (* Output to control the LED lights *)
    EnergyMode : BOOL; (* Output to indicate the energy-saving mode status *)
END_VAR
VAR
    state : INT; (* Current state of the system *)
    prevState : INT; (* Previous state of the system for debugging or monitoring *)
END_VAR

(* Initialization *)
IF state = 0 THEN
    state := 0; (* Start in IDLE state *)
END_IF

(* Finite State Machine (FSM) Logic *)
CASE state OF
    (* STATE 0: IDLE *)
    0:
        (* Outputs for IDLE state *)
        Light := FALSE;
        EnergyMode := EnergySaving;
        
        (* Transitions *)
        IF MotionSensor = TRUE THEN
            prevState := state; (* Save current state before transition *)
            state := 1; (* Transition to STATE 1: MOTION DETECTED *)
        ELSIF MotionSensor = FALSE THEN
            prevState := state; (* Save current state before transition *)
            state := 2; (* Transition to STATE 2: AMBIENT LIGHT CONTROL *)
        END_IF;

    (* STATE 1: MOTION DETECTED *)
    1:
        (* Outputs for MOTION DETECTED state *)
        Light := TRUE;
        EnergyMode := FALSE;
        
        (* Transitions *)
        IF MotionSensor = FALSE THEN
            prevState := state; (* Save current state before transition *)
            state := 0; (* Transition back to STATE 0: IDLE *)
        END_IF;

    (* STATE 2: AMBIENT LIGHT CONTROL *)
    2:
        (* Outputs for AMBIENT LIGHT CONTROL state *)
        IF (AmbientLight < 50.0) AND (EnergySaving = FALSE) THEN
            Light := TRUE;
        ELSE
            Light := FALSE;
        END_IF;
        EnergyMode := EnergySaving;
        
        (* Transitions *)
        IF MotionSensor = TRUE THEN
            prevState := state; (* Save current state before transition *)
            state := 1; (* Transition to STATE 1: MOTION DETECTED *)
        END_IF;

    (* Default case to handle unexpected states *)
    ELSE
        (* Reset to IDLE state in case of an invalid state *)
        state := 0;
END_CASE;

END_FUNCTION_BLOCK
END_ST