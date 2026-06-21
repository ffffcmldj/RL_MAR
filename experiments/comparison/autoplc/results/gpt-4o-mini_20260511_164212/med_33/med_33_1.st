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
    ColorDetected : BOOL := FALSE;    (* Variable to track if any color is detected *)
END_VAR

(* Main control logic *)
IF ColorSensorRed THEN
    RoboticArmMove := TRUE;
    BinRed := TRUE;
    BinGreen := FALSE;
    BinBlue := FALSE;
    ColorDetected := TRUE;
ELSIF ColorSensorGreen THEN
    RoboticArmMove := TRUE;
    BinRed := FALSE;
    BinGreen := TRUE;
    BinBlue := FALSE;
    ColorDetected := TRUE;
ELSIF ColorSensorBlue THEN
    RoboticArmMove := TRUE;
    BinRed := FALSE;
    BinGreen := FALSE;
    BinBlue := TRUE;
    ColorDetected := TRUE;
ELSE
    RoboticArmMove := FALSE;
    BinRed := FALSE;
    BinGreen := FALSE;
    BinBlue := FALSE;
    ColorDetected := FALSE;
END_IF;

END_FUNCTION_BLOCK