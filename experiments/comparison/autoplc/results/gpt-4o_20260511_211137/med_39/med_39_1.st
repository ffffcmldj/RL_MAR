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
    currentWindSpeed : REAL;
END_VAR

(* Initialization *)
currentWindSpeed := WindSpeedSensor;

(* Continuous Monitoring and Control Output Adjustment *)
IF currentWindSpeed <= 3.0 THEN
    (* Low Wind Speed State *)
    BladePitch := -5;
    GeneratorSpeed := 500.0;
ELSIF currentWindSpeed > 3.0 AND currentWindSpeed <= 5.0 THEN
    (* Moderate Wind Speed State *)
    BladePitch := 0;
    GeneratorSpeed := 800.0;
ELSE
    (* High Wind Speed State *)
    BladePitch := 5;
    GeneratorSpeed := 1000.0;
END_IF

END_FUNCTION_BLOCK