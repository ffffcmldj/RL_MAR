FUNCTION_BLOCK DoughMixerControl
VAR
    IngredientsDetected : BOOL;
    MixingInProgress : BOOL;
    MixingTimeElapsed : TIME;
END_VAR

VAR
    MixingTimeLimit : TIME := T#5S;
    PrevIngredientsDetected : BOOL := FALSE;
END_VAR


    IF IngredientsDetected = TRUE AND PrevIngredientsDetected = FALSE THEN
        MixingInProgress := TRUE;
        MixingTimeElapsed := T#0S;
    END_IF;

    IF MixingInProgress = TRUE THEN
        MixingTimeElapsed := MixingTimeElapsed + T#1S;
    END_IF;

    IF MixingTimeElapsed >= MixingTimeLimit THEN
        MixingInProgress := FALSE;
    END_IF;

    IF IngredientsDetected = FALSE AND MixingInProgress = TRUE THEN
        MixingInProgress := FALSE;
    END_IF;

    PrevIngredientsDetected := IngredientsDetected;
END_FUNCTION_BLOCK