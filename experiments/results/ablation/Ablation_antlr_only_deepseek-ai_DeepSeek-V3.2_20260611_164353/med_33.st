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
    (* Internal variable to track which color is currently active *)
    ActiveColor : INT := 0;
END_VAR

(* Arm movement logic: Move if ANY color sensor is active *)
RoboticArmMove := ColorSensorRed OR ColorSensorGreen OR ColorSensorBlue;

(* Determine which color is detected with priority: Red > Green > Blue *)
IF RoboticArmMove THEN
    IF ColorSensorRed THEN
        ActiveColor := 1;      (* Red has highest priority *)
    ELSIF ColorSensorGreen THEN
        ActiveColor := 2;      (* Green has medium priority *)
    ELSIF ColorSensorBlue THEN
        ActiveColor := 3;      (* Blue has lowest priority *)
    ELSE
        ActiveColor := 0;      (* Safety fallback *)
    END_IF;
ELSE
    ActiveColor := 0;          (* No color detected *)
END_IF;

(* Activate exactly one bin based on the detected color *)
CASE ActiveColor OF
    1:  (* Red detected *)
        BinRed := TRUE;
        BinGreen := FALSE;
        BinBlue := FALSE;
        
    2:  (* Green detected *)
        BinRed := FALSE;
        BinGreen := TRUE;
        BinBlue := FALSE;
        
    3:  (* Blue detected *)
        BinRed := FALSE;
        BinGreen := FALSE;
        BinBlue := TRUE;
        
    ELSE  (* No color detected or error state *)
        BinRed := FALSE;
        BinGreen := FALSE;
        BinBlue := FALSE;
END_CASE;

END_FUNCTION_BLOCK