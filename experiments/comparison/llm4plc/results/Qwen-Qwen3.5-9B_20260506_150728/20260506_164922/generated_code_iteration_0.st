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
    currentWindState : INT; // THE STATE VARIABLE TRACKING CURRENT WIND CONDITION
    targetBladePitch : INT; // INTERMEDIATE VARIABLE TO HOLD CALCULATED PITCH
    targetGenSpeed : REAL; // INTERMEDIATE VARIABLE TO HOLD CALCULATED SPEED
    windSpeedSensor : REAL; // INPUT VARIABLE (SHADOW COPY FOR LOGIC CLARITY)
    generatorSpeedSensor : REAL; // INPUT VARIABLE (SHADOW COPY FOR LOGIC CLARITY)
END_VAR

(* Initialize state to LOW_WIND_MODE (0) on first execution or reset *)
IF currentWindState = 0 AND (NOT (WindSpeedSensor > 3.0)) THEN
    currentWindState := 0;
ELSIF currentWindState = 0 AND (WindSpeedSensor > 3.0) THEN
    currentWindState := 1;
ELSIF currentWindState = 1 AND (WindSpeedSensor <= 3.0) THEN
    currentWindState := 0;
ELSIF currentWindState = 1 AND (WindSpeedSensor > 5.0) THEN
    currentWindState := 2;
ELSIF currentWindState = 2 AND (WindSpeedSensor <= 5.0) THEN
    currentWindState := 1;
ELSIF currentWindState = 2 AND (WindSpeedSensor <= 3.0) THEN
    currentWindState := 0; (* Direct jump to lowest state if wind drops significantly *)
END_IF

(* Assign output values based on the determined state *)
CASE currentWindState OF
    0: (* LOW_WIND_MODE *)
        targetBladePitch := -5;
        targetGenSpeed := 500.0;
    1: (* MODERATE_WIND_MODE *)
        targetBladePitch := 0;
        targetGenSpeed := 800.0;
    2: (* HIGH_WIND_MODE *)
        targetBladePitch := 5;
        targetGenSpeed := 1000.0;
END_CASE

(* Assign calculated targets to actual outputs *)
BladePitch := targetBladePitch;
GeneratorSpeed := targetGenSpeed;

END_FUNCTION_BLOCK
END_ST