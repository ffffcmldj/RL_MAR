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

(* Initialize internal variables *)
RecipeValid := FALSE;
IngredientsAvailable := FALSE;

(* Validate customer preference and check ingredient availability *)
CASE CustomerPreference OF
    1: (* Recipe 1: Banana, Berry Mix, Yogurt *)
        RecipeValid := TRUE;
        IngredientsAvailable := BananaAvailable AND BerryMixAvailable AND YogurtAvailable;
    2: (* Recipe 2: Berry Mix, Spinach, Yogurt *)
        RecipeValid := TRUE;
        IngredientsAvailable := BerryMixAvailable AND SpinachAvailable AND YogurtAvailable;
    3: (* Recipe 3: Banana, Spinach, Yogurt *)
        RecipeValid := TRUE;
        IngredientsAvailable := BananaAvailable AND SpinachAvailable AND YogurtAvailable;
    ELSE
        RecipeValid := FALSE;
        IngredientsAvailable := FALSE;
END_CASE;

(* Control outputs based on validation and availability *)
IF RecipeValid AND IngredientsAvailable THEN
    BlenderMotor := TRUE;
    Dispenser := TRUE;
ELSE
    BlenderMotor := FALSE;
    Dispenser := FALSE;
END_IF;

END_FUNCTION_BLOCK