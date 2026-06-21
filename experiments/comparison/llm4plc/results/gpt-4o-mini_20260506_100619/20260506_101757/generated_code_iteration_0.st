ructured-text
START_ST
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
    state : INT;       (* The state variable *)
    prevState : INT;   (* The previous state variable *)
END_VAR

(* State Definitions *)
CONST
    IDLE : INT := 0;
    SORTING_RED : INT := 1;
    SORTING_GREEN : INT := 2;
    SORTING_BLUE : INT := 3;
END_CONST

(* State Machine Logic *)
CASE state OF
    IDLE:
        RoboticArmMove := FALSE;
        BinRed := FALSE;
        BinGreen := FALSE;
        BinBlue := FALSE;
        
        IF ColorSensorRed THEN
            state := SORTING_RED;
        ELSIF ColorSensorGreen THEN
            state := SORTING_GREEN;
        ELSIF ColorSensorBlue THEN
            state := SORTING_BLUE;
        END_IF;

    SORTING_RED:
        RoboticArmMove := TRUE;
        BinRed := TRUE;
        BinGreen := FALSE;
        BinBlue := FALSE;

        IF NOT ColorSensorRed AND NOT ColorSensorGreen AND NOT ColorSensorBlue THEN
            state := IDLE;
        END_IF;

    SORTING_GREEN:
        RoboticArmMove := TRUE;
        BinRed := FALSE;
        BinGreen := TRUE;
        BinBlue := FALSE;

        IF NOT ColorSensorRed AND NOT ColorSensorGreen AND NOT ColorSensorBlue THEN
            state := IDLE;
        END_IF;

    SORTING_BLUE:
        RoboticArmMove := TRUE;
        BinRed := FALSE;
        BinGreen := FALSE;
        BinBlue := TRUE;

        IF NOT ColorSensorRed AND NOT ColorSensorGreen AND NOT ColorSensorBlue THEN
            state := IDLE;
        END_IF;

    ELSE
        state := IDLE;  (* Default to IDLE if an unknown state is encountered *)
END_CASE;

END_FUNCTION_BLOCK
END_ST