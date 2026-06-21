FUNCTION_BLOCK DoughMixerControl
    VAR_INPUT
        IngredientsDetected : BOOL;
    END_VAR

    VAR_OUTPUT
        MixingInProgress : BOOL;
    END_VAR

    VAR
        MixingTimeElapsed : TIME;
        MixingTimeLimit : TIME := T#5S;
        LastIngredientsDetected : BOOL;
    END_VAR

    IF IngredientsDetected AND NOT LastIngredientsDetected THEN
        MixingInProgress := TRUE;
        MixingTimeElapsed := T#0S;
    ELSIF NOT IngredientsDetected OR MixingTimeElapsed >= MixingTimeLimit THEN
        MixingInProgress := FALSE;
    END_IF;

    IF MixingInProgress THEN
        MixingTimeElapsed := MixingTimeElapsed + T#1S;
    END_IF;

    LastIngredientsDetected := IngredientsDetected;
END_FUNCTION_BLOCK;