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
    state : INT := 0;                 (* Current state of the FSM (0: IDLE, 1: RED_SORTING, 2: GREEN_SORTING, 3: BLUE_SORTING) *)
    prevState : INT := 0;             (* Previous state for diagnostics *)
END_VAR

(* Finite State Machine (FSM) for Robotic Arm Color Sorting *)
CASE state OF
    0: (* IDLE STATE *)
        (* Set outputs for IDLE state *)
        RoboticArmMove := FALSE;
        BinRed := FALSE;
        BinGreen := FALSE;
        BinBlue := FALSE;
        
        (* Transitions from IDLE to sorting states *)
        (* Priority: Red > Green > Blue, to handle multiple sensor conflicts *)
        IF ColorSensorRed AND NOT ColorSensorGreen AND NOT ColorSensorBlue THEN
            state := 1; (* Transition to RED_SORTING *)
        ELSIF ColorSensorGreen AND NOT ColorSensorBlue THEN
            state := 2; (* Transition to GREEN_SORTING *)
        ELSIF ColorSensorBlue THEN
            state := 3; (* Transition to BLUE_SORTING *)
        END_IF;
        
    1: (* RED_SORTING STATE *)
        (* Set outputs for RED_SORTING state *)
        RoboticArmMove := TRUE;
        BinRed := TRUE;
        BinGreen := FALSE;
        BinBlue := FALSE;
        
        (* Transition from RED_SORTING to IDLE when red sensor is FALSE *)
        (* Specification: arm stops when no colors are detected. We interpret this as the specific color sensor becomes FALSE. *)
        IF NOT ColorSensorRed THEN
            state := 0; (* Transition to IDLE *)
        END_IF;
        
    2: (* GREEN_SORTING STATE *)
        (* Set outputs for GREEN_SORTING state *)
        RoboticArmMove := TRUE;
        BinRed := FALSE;
        BinGreen := TRUE;
        BinBlue := FALSE;
        
        (* Transition from GREEN_SORTING to IDLE when green sensor is FALSE *)
        IF NOT ColorSensorGreen THEN
            state := 0; (* Transition to IDLE *)
        END_IF;
        
    3: (* BLUE_SORTING STATE *)
        (* Set outputs for BLUE_SORTING state *)
        RoboticArmMove := TRUE;
        BinRed := FALSE;
        BinGreen := FALSE;
        BinBlue := TRUE;
        
        (* Transition from BLUE_SORTING to IDLE when blue sensor is FALSE *)
        IF NOT ColorSensorBlue THEN
            state := 0; (* Transition to IDLE *)
        END_IF;
        
END_CASE;

(* Store previous state for diagnostics (optional) *)
prevState := state;

END_FUNCTION_BLOCK
END_ST