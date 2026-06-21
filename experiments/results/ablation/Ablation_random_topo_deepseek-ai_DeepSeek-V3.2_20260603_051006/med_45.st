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

// Initialize outputs and internal variables
BlenderMotor := FALSE;
Dispenser := FALSE;
RecipeValid := FALSE;
IngredientsAvailable := FALSE;

// Determine recipe validity and ingredient availability based on customer preference
CASE CustomerPreference OF
    1: // Recipe 1: Banana, Berry Mix, Yogurt
        RecipeValid := TRUE;
        IngredientsAvailable := BananaAvailable AND BerryMixAvailable AND YogurtAvailable;
        
    2: // Recipe 2: Berry Mix, Spinach, Yogurt
        RecipeValid := TRUE;
        IngredientsAvailable := BerryMixAvailable AND SpinachAvailable AND YogurtAvailable;
        
    3: // Recipe 3: Banana, Spinach, Yogurt
        RecipeValid := TRUE;
        IngredientsAvailable := BananaAvailable AND SpinachAvailable AND YogurtAvailable;
        
    ELSE
        // Invalid preference
        RecipeValid := FALSE;
        IngredientsAvailable := FALSE;
END_CASE;

// Control blender motor and dispenser based on recipe validity and ingredient availability
IF RecipeValid AND IngredientsAvailable THEN
    Dispenser := TRUE;
    BlenderMotor := TRUE;
ELSE
    Dispenser := FALSE;
    BlenderMotor := FALSE;
END_IF;

END_FUNCTION_BLOCK