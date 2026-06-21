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

    RecipeValid := FALSE;
    IngredientsAvailable := FALSE;

    CASE CustomerPreference OF
        1:
            IF BananaAvailable AND BerryMixAvailable AND YogurtAvailable THEN
                RecipeValid := TRUE;
                IngredientsAvailable := TRUE;
            END_IF;
        2:
            IF BerryMixAvailable AND SpinachAvailable AND YogurtAvailable THEN
                RecipeValid := TRUE;
                IngredientsAvailable := TRUE;
            END_IF;
        3:
            IF BananaAvailable AND SpinachAvailable AND YogurtAvailable THEN
                RecipeValid := TRUE;
                IngredientsAvailable := TRUE;
            END_IF;
        ELSE
            RecipeValid := FALSE;
            IngredientsAvailable := FALSE;
    END_CASE;

    IF RecipeValid AND IngredientsAvailable THEN
        BlenderMotor := TRUE;
        Dispenser := TRUE;
    ELSE
        BlenderMotor := FALSE;
        Dispenser := FALSE;
    END_IF;
END_FUNCTION_BLOCK;