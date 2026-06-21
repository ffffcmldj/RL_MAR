START_ST
FUNCTION_BLOCK SandwichMaker
VAR_INPUT
    BreadFeeder : BOOL; (* Input: Detects the presence of bread slices *)
    Ingredient1 : BOOL; (* Input: Detects the presence of Ingredient 1 (e.g., cheese) *)
    Ingredient2 : BOOL; (* Input: Detects the presence of Ingredient 2 (e.g., lettuce) *)
    Ingredient3 : BOOL; (* Input: Detects the presence of Ingredient 3 (e.g., tomatoes) *)
    Condiment1 : BOOL; (* Input: Detects the presence of Condiment 1 (e.g., mayo) *)
    Condiment2 : BOOL; (* Input: Detects the presence of Condiment 2 (e.g., mustard) *)
END_VAR
VAR_OUTPUT
    ConveyorMotor : BOOL; (* Output: Controls the conveyor belt motor *)
    AssembleMotor : BOOL; (* Output: Controls the sandwich assembly motor *)
END_VAR
VAR
    SliceCount : INT := 0; (* Counter for bread slices *)
    State : INT := 0; (* Current State: 0=IDLE, 1=CONVEYING, 2=ASSEMBLING *)
    AllIngredientsPresent : BOOL; (* Helper variable for ingredient check *)
END_VAR
END_VAR

BEGIN
    (* 1. Determine if all ingredients and condiments are present *)
    AllIngredientsPresent := (Ingredient1 AND Ingredient2 AND Ingredient3 AND Condiment1 AND Condiment2);

    (* 2. State Machine Logic *)
    CASE State OF
        (* STATE 0: IDLE *)
        (* Description: System is waiting for bread. Both motors are OFF. *)
        0 ->
            ConveyorMotor := FALSE;
            AssembleMotor := FALSE;

            (* Transition to STATE 1 (CONVEYING) *)
            (* Condition: Bread is detected *)
            IF BreadFeeder THEN
                State := 1;
            END_IF;

        (* STATE 1: CONVEYING *)
        (* Description: Bread has been detected. ConveyorMotor is ON. SliceCount is incremented. *)
        1 ->
            ConveyorMotor := TRUE;
            AssembleMotor := FALSE;

            (* Increment slice count if bread is present *)
            IF BreadFeeder THEN
                SliceCount := SliceCount + 1;
            END_IF;

            (* Check transition conditions *)
            (* Transition to STATE 2 (ASSEMBLING): Count >= 2 AND All Ingredients Present *)
            IF (SliceCount >= 2) AND AllIngredientsPresent THEN
                State := 2;
            (* Transition to STATE 0 (IDLE/RESET): Bread leaves sensor (BreadFeeder becomes FALSE) *)
            (* This implies the sandwich has moved past the sensor, so we reset for the next cycle *)
            ELSEIF NOT BreadFeeder THEN
                State := 0;
                SliceCount := 0; (* Reset counter when bread is no longer detected *)
            END_IF;

        (* STATE 2: ASSEMBLING *)
        (* Description: At least two bread slices are present AND all ingredients/condiments are present. *)
        (* AssembleMotor is ON. ConveyorMotor remains ON to push the sandwich. *)
        2 ->
            ConveyorMotor := TRUE;
            AssembleMotor := TRUE;

            (* Logic to exit State 2 *)
            (* Transition to STATE 0 (RESET): Bread leaves sensor (BreadFeeder becomes FALSE) *)
            (* This signifies the sandwich is complete and leaving the station *)
            IF NOT BreadFeeder THEN
                State := 0;
                SliceCount := 0; (* Reset counter *)
            (* Transition back to STATE 1 (CONVEYING): If bread is present but conditions fail *)
            (* e.g., Count < 2 or Ingredients missing *)
            ELSEIF NOT ((SliceCount >= 2) AND AllIngredientsPresent) THEN
                State := 1;
            END_IF;

        (* STATE 3: RESET (Not explicitly used in the simplified flow above as transitions go 2->0 directly,
           but included here for completeness if logic were expanded. Based on plan, 0 covers IDLE/RESET. *)
        3 ->
            ConveyorMotor := FALSE;
            AssembleMotor := FALSE;
            SliceCount := 0;
    ENDCASE
END_FUNCTION_BLOCK
END_ST