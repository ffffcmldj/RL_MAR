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
    PrevBreadState : BOOL := FALSE; (* Previous state for edge detection *)
    AllIngredientsPresent : BOOL := FALSE; (* Combined ingredient condition *)
END_VAR

(* Edge detection for bread slice counting *)
IF BreadFeeder AND NOT PrevBreadState THEN
    SliceCount := SliceCount + 1;
END_IF;

(* Update previous state for next scan cycle *)
PrevBreadState := BreadFeeder;

(* Conveyor motor control: Run when bread is detected *)
ConveyorMotor := BreadFeeder;

(* Check if all ingredients and condiments are present *)
AllIngredientsPresent := Ingredient1 AND Ingredient2 AND Ingredient3 AND Condiment1 AND Condiment2;

(* Assembly motor control: Activate only when all conditions are met *)
AssembleMotor := (SliceCount >= 2) AND AllIngredientsPresent;

(* Reset slice counter after successful assembly *)
IF AssembleMotor THEN
    SliceCount := SliceCount - 2;
END_IF;

END_FUNCTION_BLOCK