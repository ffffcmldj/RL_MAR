ructured-text
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
    state : INT; (* The state variable to track current state *)
    prevState : INT; (* The previous state variable (optional for state change logic) *)
    WindSpeed : REAL; (* The current wind speed from WindSpeedSensor *)
    GeneratorSpeed : REAL; (* The current generator speed from GeneratorSpeedSensor *)
END_VAR

(* Initialize the state variable to a default state (LOW WIND SPEED) *)
state := 0;

(* Main control logic *)
IF WindSpeedSensor <= 3.0 THEN
    state := 0; (* LOW WIND SPEED *)
ELSIF WindSpeedSensor > 3.0 AND WindSpeedSensor <= 5.0 THEN
    state := 1; (* MODERATE WIND SPEED *)
ELSIF WindSpeedSensor > 5.0 THEN
    state := 2; (* HIGH WIND SPEED *)
END_IF;

(* Set outputs based on the current state *)
CASE state OF
    0: (* LOW WIND SPEED *)
        BladePitch := -5;
        GeneratorSpeed := 500;
    1: (* MODERATE WIND SPEED *)
        BladePitch := 0;
        GeneratorSpeed := 800;
    2: (* HIGH WIND SPEED *)
        BladePitch := 5;
        GeneratorSpeed := 1000;
END_CASE;

END_FUNCTION_BLOCK
END_ST