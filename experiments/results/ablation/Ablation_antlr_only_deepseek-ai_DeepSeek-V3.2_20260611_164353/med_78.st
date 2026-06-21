(*
    FUNCTION_BLOCK: RetractableRoofControl
    DESCRIPTION: Controls a motorized retractable roof based on weather conditions.
    PRIORITY LOGIC:
        1. Combined Rain & Wind (Highest Priority): Close roof immediately.
        2. Rain Only: Close roof.
        3. Low Temperature (< 20.0°C): Close roof.
        4. Normal Conditions: Open roof.
    NOTES:
        - This is a simplified, single-output control block per the original specification.
        - The extensive I/O list and state machine from agent brQT are noted but not implemented,
          as they represent a significantly more complex system beyond the core task.
*)

FUNCTION_BLOCK RetractableRoofControl
VAR_INPUT
    RainSensor : BOOL;           (* TRUE = Rain detected *)
    WindSensor : BOOL;           (* TRUE = Strong wind detected *)
    TemperatureSensor : REAL;    (* Current ambient temperature *)
END_VAR
VAR_OUTPUT
    RoofMotor : BOOL;            (* TRUE = Close roof, FALSE = Open roof *)
END_VAR
VAR
    fTempThreshold : REAL := 20.0; (* Configurable temperature threshold *)
END_VAR

    (* Evaluate conditions in strict priority order *)
    IF (RainSensor AND WindSensor) THEN
        (* Priority 1: Combined Rain and Wind *)
        RoofMotor := TRUE;
    ELSIF (RainSensor) THEN
        (* Priority 2: Rain Only *)
        RoofMotor := TRUE;
    ELSIF (TemperatureSensor < fTempThreshold) THEN
        (* Priority 3: Low Temperature *)
        RoofMotor := TRUE;
    ELSE
        (* Priority 4: Normal Conditions *)
        RoofMotor := FALSE;
    END_IF;

END_FUNCTION_BLOCK;