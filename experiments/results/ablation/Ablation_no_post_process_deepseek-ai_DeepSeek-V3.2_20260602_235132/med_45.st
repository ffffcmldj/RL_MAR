FUNCTION_BLOCK AutomatedSmoothieMaker
VAR_INPUT
    BananaAvailable : BOOL;
    BerryMixAvailable : BOOL;
    SpinachAvailable : BOOL;
    YogurtAvailable : BOOL;
    CustomerPreference : INT;
END_VAR

VAR_OUTPUT
    BlenderMotor : BOOL;
    Dispenser : BOOL;
END_VAR

VAR
    RecipeValid : BOOL;
    IngredientsAvailable : BOOL;
END_VAR

(* Initialize outputs to safe state *)
BlenderMotor := FALSE;
Dispenser := FALSE;

(* Reset internal flags *)
RecipeValid := FALSE;
IngredientsAvailable := FALSE;

(* Validate customer preference and check ingredient availability *)
CASE CustomerPreference OF
    1:
        RecipeValid := TRUE;
        IngredientsAvailable := BananaAvailable AND BerryMixAvailable AND YogurtAvailable;
    2:
        RecipeValid := TRUE;
        IngredientsAvailable := BerryMixAvailable AND SpinachAvailable AND YogurtAvailable;
    3:
        RecipeValid := TRUE;
        IngredientsAvailable := BananaAvailable AND SpinachAvailable AND YogurtAvailable;
    ELSE
        RecipeValid := FALSE;
        IngredientsAvailable := FALSE;
END_CASE;

(* Activate outputs only when recipe is valid AND all ingredients are available *)
IF RecipeValid AND IngredientsAvailable THEN
    Dispenser := TRUE;
    BlenderMotor := TRUE;
ELSE
    Dispenser := FALSE;
    BlenderMotor := FALSE;
END_IF;

END_FUNCTION_BLOCK