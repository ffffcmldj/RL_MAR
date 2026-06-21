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
    BreadFeederPrev : BOOL := FALSE; (* Previous state for edge detection *)
END_VAR

(* Conveyor motor control and slice counting *)
IF BreadFeeder THEN
    ConveyorMotor := TRUE;
    
    (* Count bread slices on rising edge *)
    IF NOT BreadFeederPrev THEN
        SliceCount := SliceCount + 1;
    END_IF;
ELSE
    ConveyorMotor := FALSE;
END_IF;

(* Store current BreadFeeder state for next cycle *)
BreadFeederPrev := BreadFeeder;

(* Assembly motor control *)
IF (SliceCount >= 2) AND 
   Ingredient1 AND Ingredient2 AND Ingredient3 AND 
   Condiment1 AND Condiment2 THEN
    AssembleMotor := TRUE;
ELSE
    AssembleMotor := FALSE;
END_IF;

END_FUNCTION_BLOCK