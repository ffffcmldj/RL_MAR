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
    (* Internal variables can be added here if needed *)
END_VAR

(* Main control logic *)
IF WindSpeedSensor > 5.0 THEN
    (* High wind speed: > 5.0 m/s *)
    BladePitch := 5;
    GeneratorSpeed := 1000.0;
ELSIF WindSpeedSensor > 3.0 THEN
    (* Moderate wind speed: > 3.0 and <= 5.0 m/s *)
    BladePitch := 0;
    GeneratorSpeed := 800.0;
ELSE
    (* Low wind speed: <= 3.0 m/s *)
    BladePitch := -5;
    GeneratorSpeed := 500.0;
END_IF;

END_FUNCTION_BLOCK