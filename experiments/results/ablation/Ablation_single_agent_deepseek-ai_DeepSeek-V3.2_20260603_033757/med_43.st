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
    fbBreadRTrig : R_TRIG; (* Rising edge detector for bread detection *)
END_VAR

(* Detect rising edge of BreadFeeder to count slices *)
fbBreadRTrig(CLK := BreadFeeder);

(* Control conveyor motor based on bread presence *)
ConveyorMotor := BreadFeeder;

(* Increment slice count when bread is newly detected *)
IF fbBreadRTrig.Q THEN
    SliceCount := SliceCount + 1;
END_IF;

(* Control assembly motor based on conditions *)
AssembleMotor := (SliceCount >= 2) AND 
                 Ingredient1 AND 
                 Ingredient2 AND 
                 Ingredient3 AND 
                 Condiment1 AND 
                 Condiment2;

(* Reset slice count after assembly starts to prepare for next sandwich *)
IF AssembleMotor THEN
    SliceCount := 0;
END_IF;

END_FUNCTION_BLOCK