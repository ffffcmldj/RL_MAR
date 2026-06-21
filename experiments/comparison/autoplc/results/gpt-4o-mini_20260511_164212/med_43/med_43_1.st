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
END_VAR

(* Main control logic *)
IF BreadFeeder THEN
    ConveyorMotor := TRUE; (* Activate conveyor motor *)
    SliceCount := SliceCount + 1; (* Increment slice count *)
ELSE
    ConveyorMotor := FALSE; (* Stop conveyor motor *)
END_IF;

IF SliceCount >= 2 AND Ingredient1 AND Ingredient2 AND Ingredient3 AND Condiment1 AND Condiment2 THEN
    AssembleMotor := TRUE; (* Activate assembly motor *)
ELSE
    AssembleMotor := FALSE; (* Stop assembly motor *)
END_IF;

END_FUNCTION_BLOCK