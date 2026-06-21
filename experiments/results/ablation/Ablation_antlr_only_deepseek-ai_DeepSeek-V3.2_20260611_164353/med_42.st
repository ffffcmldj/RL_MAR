FUNCTION_BLOCK RetractableRoofControl
VAR_INPUT
    RainSensor : BOOL; (* TRUE = rain detected, FALSE = no rain *)
    WindSensor : BOOL; (* TRUE = wind detected, FALSE = no wind *)
    TemperatureSensor : REAL; (* Current temperature in degrees Celsius *)
END_VAR

VAR_OUTPUT
    RoofMotor : BOOL; (* TRUE = motor active (close/partially close), FALSE = motor inactive (open/fully closed) *)
END_VAR

VAR
    (* No internal variables required for this logic *)
END_VAR

(* 
    Control Logic for Motorized Retractable Roof:
    1. Rain AND Wind: Close completely (RoofMotor = FALSE)
    2. Rain AND NOT Wind: Partially close (RoofMotor = TRUE)
    3. NOT Rain AND Temperature < 20.0°C: Close slightly (RoofMotor = TRUE)
    4. NOT Rain AND Temperature >= 20.0°C: Open fully (RoofMotor = FALSE)
    
    Priority is implicit in the IF-ELSIF structure.
*)

BEGIN
    IF RainSensor AND WindSensor THEN
        RoofMotor := FALSE; (* Close completely *)
    ELSIF RainSensor AND NOT WindSensor THEN
        RoofMotor := TRUE; (* Partially close *)
    ELSIF NOT RainSensor AND TemperatureSensor < 20.0 THEN
        RoofMotor := TRUE; (* Close slightly *)
    ELSIF NOT RainSensor AND TemperatureSensor >= 20.0 THEN
        RoofMotor := FALSE; (* Open fully *)
    ELSE
        (* Fallback/default case - maintain current state *)
        RoofMotor := RoofMotor;
    END_IF;
END_FUNCTION_BLOCK