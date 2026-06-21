FUNCTION_BLOCK RetractableRoofControl
VAR_INPUT
    RainSensor : BOOL;           (* TRUE when rain is detected *)
    WindSensor : BOOL;           (* TRUE when strong wind is detected *)
    TemperatureSensor : REAL;    (* Current temperature in degrees *)
END_VAR

VAR_OUTPUT
    RoofMotor : BOOL;            (* TRUE to close roof, FALSE to open roof *)
END_VAR

VAR
    CombinedCondition : BOOL;    (* Rain AND Wind condition *)
    RainOnlyCondition : BOOL;    (* Rain without strong wind *)
    LowTempCondition : BOOL;     (* Temperature below threshold *)
    TempThreshold : REAL := 20.0; (* Temperature threshold for closing roof *)
END_VAR

(* Evaluate conditions in order of priority *)
CombinedCondition := RainSensor AND WindSensor;
RainOnlyCondition := RainSensor AND NOT CombinedCondition;
LowTempCondition := (TemperatureSensor < TempThreshold) AND NOT CombinedCondition AND NOT RainOnlyCondition;

(* Apply control logic with strict priority *)
IF CombinedCondition THEN
    (* Highest priority: Both rain and strong wind detected *)
    RoofMotor := TRUE;
ELSIF RainOnlyCondition THEN
    (* Second priority: Rain detected without strong wind *)
    RoofMotor := TRUE;
ELSIF LowTempCondition THEN
    (* Third priority: Low temperature without rain or strong wind *)
    RoofMotor := TRUE;
ELSE
    (* Normal conditions: Open the roof *)
    RoofMotor := FALSE;
END_IF;

END_FUNCTION_BLOCK;