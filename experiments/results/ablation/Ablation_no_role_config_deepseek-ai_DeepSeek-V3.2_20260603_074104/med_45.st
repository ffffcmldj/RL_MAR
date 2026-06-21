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
    Recipe1Selected : BOOL;
    Recipe2Selected : BOOL;
    Recipe3Selected : BOOL;
END_VAR

(* Determine which recipe is selected based on customer preference *)
Recipe1Selected := (CustomerPreference = 1);
Recipe2Selected := (CustomerPreference = 2);
Recipe3Selected := (CustomerPreference = 3);

(* Validate customer preference *)
RecipeValid := Recipe1Selected OR Recipe2Selected OR Recipe3Selected;

(* Check ingredient availability for the selected recipe *)
IF Recipe1Selected THEN
    IngredientsAvailable := BananaAvailable AND BerryMixAvailable AND YogurtAvailable;
ELSIF Recipe2Selected THEN
    IngredientsAvailable := BerryMixAvailable AND SpinachAvailable AND YogurtAvailable;
ELSIF Recipe3Selected THEN
    IngredientsAvailable := BananaAvailable AND SpinachAvailable AND YogurtAvailable;
ELSE
    IngredientsAvailable := FALSE;
END_IF;

(* Control outputs based on recipe validity and ingredient availability *)
BlenderMotor := RecipeValid AND IngredientsAvailable;
Dispenser := RecipeValid AND IngredientsAvailable;

END_FUNCTION_BLOCK