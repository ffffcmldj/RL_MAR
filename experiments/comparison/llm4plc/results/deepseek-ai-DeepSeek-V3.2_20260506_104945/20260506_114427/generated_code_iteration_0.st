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

(* Implementation for STATE 0: ACTIVE_CONTROL *)
(* The system continuously evaluates WindSpeedSensor to set outputs. *)
IF WindSpeedSensor <= 3.0 THEN
    BladePitch := -5;
    GeneratorSpeed := 500.0;
ELSIF (WindSpeedSensor > 3.0) AND (WindSpeedSensor <= 5.0) THEN
    BladePitch := 0;
    GeneratorSpeed := 800.0;
ELSE
    BladePitch := 5;
    GeneratorSpeed := 1000.0;
END_IF;

END_FUNCTION_BLOCK
END_ST