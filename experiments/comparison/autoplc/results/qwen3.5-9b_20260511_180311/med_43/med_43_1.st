FUNCTION_BLOCK SandwichMaker
VAR_INPUT
    BreadFeeder : BOOL;
    Ingredient1 : BOOL;
    Ingredient2 : BOOL;
    Ingredient3 : BOOL;
    Condiment1 : BOOL;
    Condiment2 : BOOL;
END_VAR
VAR_OUTPUT
    ConveyorMotor : BOOL;
    AssembleMotor : BOOL;
END_VAR
VAR
    SliceCount : INT := 0;
END_VAR

IF BreadFeeder = TRUE THEN
    ConveyorMotor := TRUE;
    SliceCount := SliceCount + 1;
ELSE
    ConveyorMotor := FALSE;
END_IF

IF SliceCount >= 2 AND Ingredient1 = TRUE AND Ingredient2 = TRUE AND Ingredient3 = TRUE AND Condiment1 = TRUE AND Condiment2 = TRUE THEN
    AssembleMotor := TRUE;
ELSE
    AssembleMotor := FALSE;
END_IF

END_FUNCTION_BLOCK