plaintext
START_ST
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
    state : INT := 0;       (* Current state of the system *)
    prevState : INT := 0;   (* Previous state of the system *)
END_VAR

(* Main execution block *)
IF state = 0 THEN
    (* STATE 0: IDLE *)
    RoboticArmMove := FALSE;
    BinRed := FALSE;
    BinGreen := FALSE;
    BinBlue := FALSE;

    (* Transition conditions from STATE 0 *)
    IF ColorSensorRed AND NOT ColorSensorGreen AND NOT ColorSensorBlue THEN
        state := 1; (* Transition to STATE 1: RED BIN ACTIVATION *)
    ELSIF NOT ColorSensorRed AND ColorSensorGreen AND NOT ColorSensorBlue THEN
        state := 2; (* Transition to STATE 2: GREEN BIN ACTIVATION *)
    ELSIF NOT ColorSensorRed AND NOT ColorSensorGreen AND ColorSensorBlue THEN
        state := 3; (* Transition to STATE 3: BLUE BIN ACTIVATION *)
    END_IF;

ELSIF state = 1 THEN
    (* STATE 1: RED BIN ACTIVATION *)
    RoboticArmMove := TRUE;
    BinRed := TRUE;
    BinGreen := FALSE;
    BinBlue := FALSE;

    (* Transition condition from STATE 1 to STATE 0 *)
    IF NOT ColorSensorRed THEN
        state := 0; (* Transition to STATE 0: IDLE *)
    END_IF;

ELSIF state = 2 THEN
    (* STATE 2: GREEN BIN ACTIVATION *)
    RoboticArmMove := TRUE;
    BinRed := FALSE;
    BinGreen := TRUE;
    BinBlue := FALSE;

    (* Transition condition from STATE 2 to STATE 0 *)
    IF NOT ColorSensorGreen THEN
        state := 0; (* Transition to STATE 0: IDLE *)
    END_IF;

ELSIF state = 3 THEN
    (* STATE 3: BLUE BIN ACTIVATION *)
    RoboticArmMove := TRUE;
    BinRed := FALSE;
    BinGreen := FALSE;
    BinBlue := TRUE;

    (* Transition condition from STATE 3 to STATE 0 *)
    IF NOT ColorSensorBlue THEN
        state := 0; (* Transition to STATE 0: IDLE *)
    END_IF;

END_IF;

(* Update previous state for monitoring or debugging purposes *)
prevState := state;

END_FUNCTION_BLOCK
END_ST