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
    AllIngredientsPresent : BOOL; (* Flag for ingredient availability *)
END_VAR

(* Edge detection for bread slice counting *)
IF BreadFeeder AND NOT PrevBreadState THEN
    SliceCount := SliceCount + 1;
END_IF;

(* Update previous bread state for next cycle *)
PrevBreadState := BreadFeeder;

(* Calculate ingredient availability *)
AllIngredientsPresent := Ingredient1 AND Ingredient2 AND Ingredient3 AND Condiment1 AND Condiment2;

(* Control conveyor motor based on bread presence *)
ConveyorMotor := BreadFeeder AND NOT AssembleMotor; (* Interlock: conveyor stops during assembly *)

(* Control assembly motor based on conditions *)
IF (SliceCount >= 2) AND AllIngredientsPresent THEN
    AssembleMotor := TRUE;
    (* Reset slice count after successful assembly *)
    SliceCount := 0;
ELSE
    AssembleMotor := FALSE;
END_IF;

(* Safety interlock: reset slice count if ingredients missing during operation *)
IF NOT AllIngredientsPresent AND SliceCount > 0 THEN
    SliceCount := 0;
END_IF;

END_FUNCTION_BLOCK