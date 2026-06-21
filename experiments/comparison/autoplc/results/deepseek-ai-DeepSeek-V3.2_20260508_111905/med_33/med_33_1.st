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
    // Internal variables to track sensor states
    redActive : BOOL;
    greenActive : BOOL;
    blueActive : BOOL;
    activeCount : INT;
END_VAR

(* Main execution logic *)
redActive := ColorSensorRed;
greenActive := ColorSensorGreen;
blueActive := ColorSensorBlue;

(* Count how many sensors are active *)
activeCount := 0;
IF redActive THEN
    activeCount := activeCount + 1;
END_IF;

IF greenActive THEN
    activeCount := activeCount + 1;
END_IF;

IF blueActive THEN
    activeCount := activeCount + 1;
END_IF;

(* Determine state based on sensor inputs *)
CASE activeCount OF
    0: (* No sensors active - Idle State *)
        RoboticArmMove := FALSE;
        BinRed := FALSE;
        BinGreen := FALSE;
        BinBlue := FALSE;
        
    1: (* Exactly one sensor active - Valid Sorting State *)
        IF redActive AND NOT greenActive AND NOT blueActive THEN
            (* Red sorting state *)
            RoboticArmMove := TRUE;
            BinRed := TRUE;
            BinGreen := FALSE;
            BinBlue := FALSE;
        ELSIF NOT redActive AND greenActive AND NOT blueActive THEN
            (* Green sorting state *)
            RoboticArmMove := TRUE;
            BinRed := FALSE;
            BinGreen := TRUE;
            BinBlue := FALSE;
        ELSIF NOT redActive AND NOT greenActive AND blueActive THEN
            (* Blue sorting state *)
            RoboticArmMove := TRUE;
            BinRed := FALSE;
            BinGreen := FALSE;
            BinBlue := TRUE;
        ELSE
            (* Fallback to idle state for unexpected single sensor condition *)
            RoboticArmMove := FALSE;
            BinRed := FALSE;
            BinGreen := FALSE;
            BinBlue := FALSE;
        END_IF;
        
    ELSE (* 2 or 3 sensors active - Conflict/Error State *)
        (* Default to idle state as safe fail-safe behavior *)
        RoboticArmMove := FALSE;
        BinRed := FALSE;
        BinGreen := FALSE;
        BinBlue := FALSE;
END_CASE;

END_FUNCTION_BLOCK