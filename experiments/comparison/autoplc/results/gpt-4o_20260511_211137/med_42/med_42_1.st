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
    isRainingAndWindy : BOOL;
    isRainingNoWind : BOOL;
    isNotRainingCold : BOOL;
    isNotRainingWarm : BOOL;
END_VAR

(* Initialization and continuous monitoring of sensor inputs *)
isRainingAndWindy := RainSensor AND WindSensor;
isRainingNoWind := RainSensor AND NOT WindSensor;
isNotRainingCold := NOT RainSensor AND (TemperatureSensor < 20.0);
isNotRainingWarm := NOT RainSensor AND (TemperatureSensor >= 20.0);

(* Decision making and state transition *)
IF isRainingAndWindy THEN
    (* Transition to Fully Closed *)
    RoofMotor := FALSE;
ELSIF isRainingNoWind THEN
    (* Transition to Partially Closed *)
    RoofMotor := TRUE;
ELSIF isNotRainingCold THEN
    (* Transition to Slightly Closed *)
    RoofMotor := TRUE;
ELSIF isNotRainingWarm THEN
    (* Transition to Fully Open *)
    RoofMotor := FALSE;
END_IF

END_FUNCTION_BLOCK