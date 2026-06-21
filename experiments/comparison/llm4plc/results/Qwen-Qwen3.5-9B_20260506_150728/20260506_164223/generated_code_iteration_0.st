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
    currentState : INT := 0; // 0=IDLE, 1=RED, 2=GREEN, 3=BLUE
END_VAR

BEGIN
    (* STATE 0 (IDLE): No color detected *)
    (* Outputs: RoboticArmMove = FALSE, BinRed = FALSE, BinGreen = FALSE, BinBlue = FALSE *)
    
    (* STATE 1 (SORTING_RED): Red detected *)
    (* Outputs: RoboticArmMove = TRUE, BinRed = TRUE, BinGreen = FALSE, BinBlue = FALSE *)
    
    (* STATE 2 (SORTING_GREEN): Green detected *)
    (* Outputs: RoboticArmMove = TRUE, BinRed = FALSE, BinGreen = TRUE, BinBlue = FALSE *)
    
    (* STATE 3 (SORTING_BLUE): Blue detected *)
    (* Outputs: RoboticArmMove = TRUE, BinRed = FALSE, BinGreen = FALSE, BinBlue = TRUE *)

    (* Transition Logic Implementation *)
    (* Priority Order: Red > Green > Blue as per plan note *)
    (* Logic: If input for current state is FALSE, go to IDLE. 
       If input for a different state is TRUE, transition to that new state. 
       If input for current state is TRUE, remain in state. *)

    (* Transition from STATE 0 (IDLE) *)
    IF currentState = 0 THEN
        IF ColorSensorRed THEN
            (* Transition 0 -> 1: Red detected *)
            currentState := 1;
        ELSIF ColorSensorGreen THEN
            (* Transition 0 -> 2: Green detected *)
            currentState := 2;
        ELSIF ColorSensorBlue THEN
            (* Transition 0 -> 3: Blue detected *)
            currentState := 3;
        END_IF;
    END_IF;

    (* Transition from STATE 1 (SORTING_RED) *)
    IF currentState = 1 THEN
        IF NOT ColorSensorRed THEN
            (* Transition 1 -> 0: Red sensor lost *)
            currentState := 0;
        ELSIF ColorSensorGreen THEN
            (* Transition 1 -> 2: Green detected while in Red state *)
            currentState := 2;
        ELSIF ColorSensorBlue THEN
            (* Transition 1 -> 3: Blue detected while in Red state *)
            currentState := 3;
        END_IF;
    END_IF;

    (* Transition from STATE 2 (SORTING_GREEN) *)
    IF currentState = 2 THEN
        IF NOT ColorSensorGreen THEN
            (* Transition 2 -> 0: Green sensor lost *)
            currentState := 0;
        ELSIF ColorSensorRed THEN
            (* Transition 2 -> 1: Red detected while in Green state *)
            currentState := 1;
        ELSIF ColorSensorBlue THEN
            (* Transition 2 -> 3: Blue detected while in Green state *)
            currentState := 3;
        END_IF;
    END_IF;

    (* Transition from STATE 3 (SORTING_BLUE) *)
    IF currentState = 3 THEN
        IF NOT ColorSensorBlue THEN
            (* Transition 3 -> 0: Blue sensor lost *)
            currentState := 0;
        ELSIF ColorSensorRed THEN
            (* Transition 3 -> 1: Red detected while in Blue state *)
            currentState := 1;
        ELSIF ColorSensorGreen THEN
            (* Transition 3 -> 2: Green detected while in Blue state *)
            currentState := 2;
        END_IF;
    END_IF;

    (* Assign Outputs based on Final Current State *)
    CASE currentState OF
        0: (* IDLE *)
            RoboticArmMove := FALSE;
            BinRed := FALSE;
            BinGreen := FALSE;
            BinBlue := FALSE;
        1: (* SORTING_RED *)
            RoboticArmMove := TRUE;
            BinRed := TRUE;
            BinGreen := FALSE;
            BinBlue := FALSE;
        2: (* SORTING_GREEN *)
            RoboticArmMove := TRUE;
            BinRed := FALSE;
            BinGreen := TRUE;
            BinBlue := FALSE;
        3: (* SORTING_BLUE *)
            RoboticArmMove := TRUE;
            BinRed := FALSE;
            BinGreen := FALSE;
            BinBlue := TRUE;
    END_CASE;

END_FUNCTION_BLOCK
END_ST