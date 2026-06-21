FUNCTION_BLOCK RetractableRoofControl
VAR_INPUT
    RainSensor : BOOL;           (* TRUE if rain is detected *)
    WindSensor : BOOL;           (* TRUE if strong wind is detected *)
    TemperatureSensor : REAL;    (* Current temperature in degrees *)
END_VAR
VAR_OUTPUT
    RoofMotor : BOOL;            (* TRUE closes roof, FALSE opens roof *)
END_VAR

(* Main control logic *)
IF RainSensor AND WindSensor THEN
    (* Combined rain and wind - highest priority *)
    RoofMotor := TRUE;
ELSIF RainSensor THEN
    (* Rain only - medium priority *)
    RoofMotor := TRUE;
ELSIF TemperatureSensor < 20.0 THEN
    (* Low temperature - lowest priority *)
    RoofMotor := TRUE;
ELSE
    (* Normal conditions - open roof *)
    RoofMotor := FALSE;
END_IF;

END_FUNCTION_BLOCK