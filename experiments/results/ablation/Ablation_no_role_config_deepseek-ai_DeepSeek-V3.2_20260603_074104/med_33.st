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

(* Internal variables for mutual exclusion logic *)
VAR
    bAnyColorDetected : BOOL;
END_VAR

(* Main logic *)
bAnyColorDetected := ColorSensorRed OR ColorSensorGreen OR ColorSensorBlue;

(* Activate robotic arm when any color is detected *)
RoboticArmMove := bAnyColorDetected;

(* Activate bins with mutual exclusion - only one bin at a time *)
(* Priority: Red > Green > Blue (can be adjusted if needed) *)
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
    (* No color detected - deactivate all bins *)
    BinRed := FALSE;
    BinGreen := FALSE;
    BinBlue := FALSE;
END_IF;

END_FUNCTION_BLOCK