FUNCTION_BLOCK RetractableRoofControl
VAR_INPUT
    RainSensor : BOOL; (* Input to detect rain *)
    WindSensor : BOOL; (* Input to detect wind *)
    TemperatureSensor : REAL; (* Input to measure temperature *)
END_VAR
VAR_OUTPUT
    RoofMotor : BOOL; (* Output to control the roof motor *)
END_VAR

VAR
    (* Temporary variable to hold the state of RoofMotor *)
    RoofState : BOOL;
END_VAR

(* Initialization of RoofMotor to a known state *)
RoofMotor := FALSE;

(* Decision Logic *)
IF RainSensor AND WindSensor THEN
    RoofMotor := FALSE; (* Roof Closed Completely *)
ELSIF RainSensor AND NOT WindSensor THEN
    RoofMotor := TRUE; (* Roof Partially Closed *)
ELSIF NOT RainSensor AND (TemperatureSensor < 20.0) THEN
    RoofMotor := TRUE; (* Roof Slightly Closed *)
ELSIF NOT RainSensor AND (TemperatureSensor >= 20.0) THEN
    RoofMotor := FALSE; (* Roof Fully Open *)
END_IF;

END_FUNCTION_BLOCK