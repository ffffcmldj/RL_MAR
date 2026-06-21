FUNCTION_BLOCK RetractableRoofControl
VAR_INPUT
    RainSensor : BOOL;           (* TRUE if rain is detected *)
    WindSensor : BOOL;           (* TRUE if strong wind is detected *)
    TemperatureSensor : REAL;    (* Current temperature in degrees *)
END_VAR
VAR_OUTPUT
    RoofMotor : BOOL;            (* TRUE = close roof, FALSE = open roof *)
END_VAR

(* Main control logic *)
IF RainSensor AND WindSensor THEN
    (* Highest priority: both rain and strong wind *)
    RoofMotor := TRUE;
ELSIF RainSensor THEN
    (* Second priority: rain only *)
    RoofMotor := TRUE;
ELSIF TemperatureSensor < 20.0 THEN
    (* Third priority: low temperature *)
    RoofMotor := TRUE;
ELSE
    (* Normal conditions: open roof *)
    RoofMotor := FALSE;
END_IF;

END_FUNCTION_BLOCK