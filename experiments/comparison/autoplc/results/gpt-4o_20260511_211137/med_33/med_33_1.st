FUNCTION_BLOCK RoboticArmColorSorting
VAR_INPUT
    ColorSensorRed : BOOL;   (* Input: Red color sensor *)
    ColorSensorGreen : BOOL; (* Input: Green color sensor *)
    ColorSensorBlue : BOOL;  (* Input: Blue color sensor *)
END_VAR

VAR_OUTPUT
    RoboticArmMove : BOOL := FALSE; (* Output: Control for robotic arm movement *)
    BinRed : BOOL := FALSE;         (* Output: Activate red bin *)
    BinGreen : BOOL := FALSE;       (* Output: Activate green bin *)
    BinBlue : BOOL := FALSE;        (* Output: Activate blue bin *)
END_VAR

VAR
    // Internal variables can be declared here if needed
END_VAR

// Main logic for controlling the robotic arm based on color detection
IF ColorSensorRed THEN
    // Red color detected
    RoboticArmMove := TRUE;
    BinRed := TRUE;
    BinGreen := FALSE;
    BinBlue := FALSE;
ELSIF ColorSensorGreen THEN
    // Green color detected and red is not detected
    RoboticArmMove := TRUE;
    BinRed := FALSE;
    BinGreen := TRUE;
    BinBlue := FALSE;
ELSIF ColorSensorBlue THEN
    // Blue color detected and neither red nor green is detected
    RoboticArmMove := TRUE;
    BinRed := FALSE;
    BinGreen := FALSE;
    BinBlue := TRUE;
ELSE
    // No color detected, go to idle state
    RoboticArmMove := FALSE;
    BinRed := FALSE;
    BinGreen := FALSE;
    BinBlue := FALSE;
END_IF

END_FUNCTION_BLOCK