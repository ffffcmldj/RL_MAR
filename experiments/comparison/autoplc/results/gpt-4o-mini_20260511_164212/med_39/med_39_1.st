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
    WindSpeed : REAL; (* Temporary variable to hold wind speed *)
END_VAR

(* Initialization of output variables *)
BladePitch := 0; 
GeneratorSpeed := 0;

(* Input Monitoring and State Evaluation *)
WindSpeed := WindSpeedSensor;

IF WindSpeed <= 3.0 THEN
    BladePitch := -5; (* Low wind speed adjustment *)
    GeneratorSpeed := 500; (* RPM for low wind speed *)
ELSIF WindSpeed > 3.0 AND WindSpeed <= 5.0 THEN
    BladePitch := 0; (* Moderate wind speed adjustment *)
    GeneratorSpeed := 800; (* RPM for moderate wind speed *)
ELSIF WindSpeed > 5.0 THEN
    BladePitch := 5; (* High wind speed adjustment *)
    GeneratorSpeed := 1000; (* RPM for high wind speed *)
END_IF;

END_FUNCTION_BLOCK