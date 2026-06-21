FUNCTION_BLOCK RoboticArmColorSorting
VAR_INPUT
    ColorSensorRed : BOOL;   (* Input: Red color sensor *)
    ColorSensorGreen : BOOL;  (* Input: Green color sensor *)
    ColorSensorBlue : BOOL;   (* Input: Blue color sensor *)
END_VAR

VAR_OUTPUT
    RoboticArmMove : BOOL := FALSE;     (* Output: Control for robotic arm movement *)
    BinRed : BOOL := FALSE;           (* Output: Activate red bin *)
    BinGreen : BOOL := FALSE;         (* Output: Activate green bin *)
    BinBlue : BOOL := FALSE;          (* Output: Activate blue bin *)
END_VAR

VAR
    AnyColorDetected : BOOL;
END_VAR

(* Main Logic *)
AnyColorDetected := ColorSensorRed OR ColorSensorGreen OR ColorSensorBlue;

RoboticArmMove := AnyColorDetected;

(* Activate bins based on exclusive color detection *)
BinRed := ColorSensorRed AND NOT ColorSensorGreen AND NOT ColorSensorBlue;
BinGreen := ColorSensorGreen AND NOT ColorSensorRed AND NOT ColorSensorBlue;
BinBlue := ColorSensorBlue AND NOT ColorSensorRed AND NOT ColorSensorGreen;

END_FUNCTION_BLOCK