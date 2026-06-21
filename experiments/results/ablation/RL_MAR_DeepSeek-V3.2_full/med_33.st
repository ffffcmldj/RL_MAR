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

(* Main logic body begins here *)
IF ColorSensorRed OR ColorSensorGreen OR ColorSensorBlue THEN
    RoboticArmMove := TRUE;
    
    (* Priority-based bin activation to ensure only one bin is active at a time *)
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
ELSE
    RoboticArmMove := FALSE;
    BinRed := FALSE;
    BinGreen := FALSE;
    BinBlue := FALSE;
END_IF;
END_FUNCTION_BLOCK;