pascal
START_ST

FUNCTION_BLOCK WindTurbineControl
VAR_INPUT
    WindSpeedSensor : REAL; (* Input for measuring wind speed *)
    GeneratorSpeedSensor : REAL; (* Input for measuring generator speed *)
END_VAR

VAR_OUTPUT
    BladePitch : INT; (* Output for blade pitch control (degrees) *)
    GeneratorSpeed : REAL; (* Output for generator speed control (RPM) *)
END_VAR

VAR
    state : INT := 0; (* Current state of the FSM *)
    prevState : INT := 0; (* Previous state of the FSM for debugging or tracking *)
END_VAR

(* Main logic of the function block *)
IF state = 0 THEN
    (* STATE 0: INITIALIZE *)
    BladePitch := 0;
    GeneratorSpeed := 0;

    (* Transition logic for STATE 0 *)
    IF WindSpeedSensor <= 3.0 THEN
        state := 1; (* Transition to STATE 1: LOW WIND SPEED *)
    ELSIF WindSpeedSensor > 3.0 AND WindSpeedSensor <= 5.0 THEN
        state := 2; (* Transition to STATE 2: MODERATE WIND SPEED *)
    ELSIF WindSpeedSensor > 5.0 THEN
        state := 3; (* Transition to STATE 3: HIGH WIND SPEED *)
    END_IF;

ELSIF state = 1 THEN
    (* STATE 1: LOW WIND SPEED *)
    BladePitch := -5;
    GeneratorSpeed := 500;

    (* Transition logic for STATE 1 *)
    IF WindSpeedSensor > 3.0 AND WindSpeedSensor <= 5.0 THEN
        state := 2; (* Transition to STATE 2: MODERATE WIND SPEED *)
    ELSIF WindSpeedSensor > 5.0 THEN
        state := 3; (* Transition to STATE 3: HIGH WIND SPEED *)
    END_IF;

ELSIF state = 2 THEN
    (* STATE 2: MODERATE WIND SPEED *)
    BladePitch := 0;
    GeneratorSpeed := 800;

    (* Transition logic for STATE 2 *)
    IF WindSpeedSensor <= 3.0 THEN
        state := 1; (* Transition to STATE 1: LOW WIND SPEED *)
    ELSIF WindSpeedSensor > 5.0 THEN
        state := 3; (* Transition to STATE 3: HIGH WIND SPEED *)
    END_IF;

ELSIF state = 3 THEN
    (* STATE 3: HIGH WIND SPEED *)
    BladePitch := 5;
    GeneratorSpeed := 1000;

    (* Transition logic for STATE 3 *)
    IF WindSpeedSensor <= 3.0 THEN
        state := 1; (* Transition to STATE 1: LOW WIND SPEED *)
    ELSIF WindSpeedSensor > 3.0 AND WindSpeedSensor <= 5.0 THEN
        state := 2; (* Transition to STATE 2: MODERATE WIND SPEED *)
    END_IF;

END_IF;

(* Update the previous state for tracking or debugging purposes *)
prevState := state;

END_FUNCTION_BLOCK

END_ST