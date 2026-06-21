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
    bAnyColorDetected : BOOL;
END_VAR

(* Determine if any color is detected *)
bAnyColorDetected := ColorSensorRed OR ColorSensorGreen OR ColorSensorBlue;

(* Control robotic arm movement: activate when any color is detected *)
RoboticArmMove := bAnyColorDetected;

(* Control bin activation based on color detection *)
(* Only one bin is active at a time, with priority if multiple sensors are active *)
(* Priority order: Red, Green, Blue *)
IF ColorSensorRed THEN
    BinRed := TRUE;
    BinGreen := FALSE;
    BinBlue := FALSE;
ELSIF ColorSensorGreen THEN
    BinRed := FALSE;
    BinGreen := TRUE;
    BinBlue := FALSE;
ELSIF ColorSensorBlue THEN
    BinRed := FALSE;
    BinGreen := FALSE;
    BinBlue := TRUE;
ELSE
    BinRed := FALSE;
    BinGreen := FALSE;
    BinBlue := FALSE;
END_IF;

END_FUNCTION_BLOCK