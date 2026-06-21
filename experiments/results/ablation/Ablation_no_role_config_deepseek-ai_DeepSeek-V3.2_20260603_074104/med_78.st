FUNCTION_BLOCK RetractableRoofControl
VAR_INPUT
    RainSensor : BOOL;           (* TRUE if rain is detected *)
    WindSensor : BOOL;           (* TRUE if strong wind is detected *)
    TemperatureSensor : REAL;    (* Current temperature in degrees *)
END_VAR
VAR_OUTPUT
    RoofMotor : BOOL;            (* TRUE closes roof, FALSE opens roof *)
END_VAR
VAR
    bCombinedCondition : BOOL;
    bRainOnlyCondition : BOOL;
    bLowTempCondition : BOOL;
END_VAR

(* Evaluate conditions *)
bCombinedCondition := RainSensor AND WindSensor;
bRainOnlyCondition := RainSensor AND NOT bCombinedCondition;
bLowTempCondition := (TemperatureSensor < 20.0) AND NOT bCombinedCondition AND NOT bRainOnlyCondition;

(* Priority-based control logic *)
IF bCombinedCondition THEN
    (* Highest priority: both rain and strong wind *)
    RoofMotor := TRUE;
ELSIF bRainOnlyCondition THEN
    (* Second priority: rain only *)
    RoofMotor := TRUE;
ELSIF bLowTempCondition THEN
    (* Third priority: low temperature *)
    RoofMotor := TRUE;
ELSE
    (* Normal conditions: open roof *)
    RoofMotor := FALSE;
END_IF;

END_FUNCTION_BLOCK