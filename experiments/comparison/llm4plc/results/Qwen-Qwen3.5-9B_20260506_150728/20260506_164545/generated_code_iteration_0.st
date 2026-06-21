START_ST
TYPE point_type :
    STRUCT
        X : INT;
        Y : INT;
    END_STRUCT;
END_TYPE

FUNCTION_BLOCK FB_PointOperations
    VAR_INPUT
        INPUT_VAR2 : INT := 7;
    END_VAR

    VAR_OUTPUT
        OUTPUT_VAR1 : point_type;
        OUTPUT_VAR3 : point_type;
    END_VAR

    VAR
        VAR2 : INT;
    END_VAR

BEGIN
    (* Assign input to internal variable *)
    VAR2 := INPUT_VAR2;

    (* Set OUTPUT_VAR1 coordinates *)
    OUTPUT_VAR1.X := 1;
    OUTPUT_VAR1.Y := 2;

    (* Set OUTPUT_VAR3 coordinates *)
    OUTPUT_VAR3.X := 100;
    OUTPUT_VAR3.Y := -7000;
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_ExpandedPoint
    VAR_INPUT
        INPUT_VAR2 : INT;
        INPUT_VAR1_X : INT;
        INPUT_VAR1_Y : INT;
        INPUT_VAR3_X : INT := 1;
        INPUT_VAR3_Y : INT := 2;
    END_VAR

    VAR_OUTPUT
        OUTPUT_VAR2 : INT;
        OUTPUT_VAR1_X : INT;
        OUTPUT_VAR1_Y : INT;
        OUTPUT_VAR3_X : INT;
        OUTPUT_VAR3_Y : INT;
    END_VAR

    VAR
        state : INT;
    END_VAR

BEGIN
    (* State Machine Logic *)
    (* STATE 0: INITIALIZE *)
    (* No outputs active, handled by sequential flow *)

    (* STATE 1: EXECUTE_POINT_OPERATIONS *)
    (* Logic: Assign inputs, set specific output values *)
    OUTPUT_VAR2 := INPUT_VAR2;
    OUTPUT_VAR1_X := 1;
    OUTPUT_VAR1_Y := 2;
    OUTPUT_VAR3_X := 100;
    OUTPUT_VAR3_Y := -7000;

    (* STATE 2: EXECUTE_EXPANDED_POINT_LOGIC *)
    (* Logic: Pass through expanded point inputs/outputs *)
    OUTPUT_VAR1_X := INPUT_VAR1_X;
    OUTPUT_VAR1_Y := INPUT_VAR1_Y;
    OUTPUT_VAR3_X := INPUT_VAR3_X;
    OUTPUT_VAR3_Y := INPUT_VAR3_Y;

    (* Note: In a real FSM, state transitions would be explicit.
       Here, the logic executes sequentially within the scan cycle
       as per the provided plan's transition requirements. *)
END_FUNCTION_BLOCK
END_ST