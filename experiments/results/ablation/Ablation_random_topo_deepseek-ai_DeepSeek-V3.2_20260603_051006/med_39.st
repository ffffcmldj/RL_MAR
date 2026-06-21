FUNCTION_BLOCK WindTurbineControl
VAR_INPUT
    WindSpeedSensor : REAL; (* Input for measuring wind speed *)
    GeneratorSpeedSensor : REAL; (* Input for measuring generator speed *)
END_VAR

VAR_OUTPUT
    BladePitch : INT; (* Output for blade pitch control (degrees) *)
    GeneratorSpeed : REAL; (* Output for generator speed control (RPM) *)
END_VAR

(* Main control logic *)
IF WindSpeedSensor <= 3.0 THEN
    (* Low wind speed condition *)
    BladePitch := -5;
    GeneratorSpeed := 500.0;
ELSIF (WindSpeedSensor > 3.0) AND (WindSpeedSensor <= 5.0) THEN
    (* Moderate wind speed condition *)
    BladePitch := 0;
    GeneratorSpeed := 800.0;
ELSIF WindSpeedSensor > 5.0 THEN
    (* High wind speed condition *)
    BladePitch := 5;
    GeneratorSpeed := 1000.0;
ELSE
    (* Fallback condition for invalid inputs *)
    BladePitch := 0;
    GeneratorSpeed := 0.0;
END_IF;

END_FUNCTION_BLOCK