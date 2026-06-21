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
    // Internal variables for state tracking (if needed)
    CurrentState : INT; (* 0: Low, 1: Moderate, 2: High *)
END_VAR

(* Main control logic *)
IF WindSpeedSensor <= 3.0 THEN
    (* Low wind speed state *)
    BladePitch := -5;
    GeneratorSpeed := 500.0;
    CurrentState := 0;
ELSIF (WindSpeedSensor > 3.0) AND (WindSpeedSensor <= 5.0) THEN
    (* Moderate wind speed state *)
    BladePitch := 0;
    GeneratorSpeed := 800.0;
    CurrentState := 1;
ELSE
    (* High wind speed state *)
    BladePitch := 5;
    GeneratorSpeed := 1000.0;
    CurrentState := 2;
END_IF;

END_FUNCTION_BLOCK