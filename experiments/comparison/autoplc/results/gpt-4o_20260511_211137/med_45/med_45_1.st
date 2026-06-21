FUNCTION_BLOCK AutomatedSmoothieMaker
VAR_INPUT
    BananaAvailable : BOOL;
    BerryMixAvailable : BOOL;
    SpinachAvailable : BOOL;
    YogurtAvailable : BOOL;
    CustomerPreference : INT;
END_VAR

VAR_OUTPUT
    BlenderMotor : BOOL := FALSE;
    Dispenser : BOOL := FALSE;
END_VAR

VAR
    IngredientsAvailable : BOOL;
END_VAR

// Main logic to control the smoothie maker
IF (CustomerPreference < 1) OR (CustomerPreference > 3) THEN
    // Invalid preference, turn off BlenderMotor and Dispenser
    BlenderMotor := FALSE;
    Dispenser := FALSE;
ELSE
    // Check ingredient availability based on customer preference
    CASE CustomerPreference OF
        1: // Recipe 1: Banana, Berry Mix, Yogurt
            IngredientsAvailable := BananaAvailable AND BerryMixAvailable AND YogurtAvailable;
        2: // Recipe 2: Berry Mix, Spinach, Yogurt
            IngredientsAvailable := BerryMixAvailable AND SpinachAvailable AND YogurtAvailable;
        3: // Recipe 3: Banana, Spinach, Yogurt
            IngredientsAvailable := BananaAvailable AND SpinachAvailable AND YogurtAvailable;
    ELSE
        IngredientsAvailable := FALSE; // Default case, should not occur
    END_CASE;

    // Control the BlenderMotor and Dispenser based on ingredient availability
    IF IngredientsAvailable THEN
        BlenderMotor := TRUE;
        Dispenser := TRUE;
    ELSE
        BlenderMotor := FALSE;
        Dispenser := FALSE;
    END_IF;
END_IF;
END_FUNCTION_BLOCK