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
    Recipe1_Ingredients_Available : BOOL;
    Recipe2_Ingredients_Available : BOOL;
    Recipe3_Ingredients_Available : BOOL;
    IsPreferenceValid : BOOL;
END_VAR


    IsPreferenceValid := FALSE;
    Recipe1_Ingredients_Available := FALSE;
    Recipe2_Ingredients_Available := FALSE;
    Recipe3_Ingredients_Available := FALSE;

    IF CustomerPreference >= 1 AND CustomerPreference <= 3 THEN
        IsPreferenceValid := TRUE;
    END_IF;

    IF IsPreferenceValid THEN
        IF CustomerPreference = 1 THEN
            Recipe1_Ingredients_Available := BananaAvailable AND BerryMixAvailable AND YogurtAvailable;
        END_IF;

        IF CustomerPreference = 2 THEN
            Recipe2_Ingredients_Available := BerryMixAvailable AND SpinachAvailable AND YogurtAvailable;
        END_IF;

        IF CustomerPreference = 3 THEN
            Recipe3_Ingredients_Available := BananaAvailable AND SpinachAvailable AND YogurtAvailable;
        END_IF;
    END_IF;

    IF Recipe1_Ingredients_Available THEN
        BlenderMotor := TRUE;
        Dispenser := TRUE;
    ELSIF Recipe2_Ingredients_Available THEN
        BlenderMotor := TRUE;
        Dispenser := TRUE;
    ELSIF Recipe3_Ingredients_Available THEN
        BlenderMotor := TRUE;
        Dispenser := TRUE;
    ELSE
        BlenderMotor := FALSE;
        Dispenser := FALSE;
    END_IF;
END_FUNCTION_BLOCK