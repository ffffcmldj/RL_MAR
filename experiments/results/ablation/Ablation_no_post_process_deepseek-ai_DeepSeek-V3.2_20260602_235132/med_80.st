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
    IngredientsDetected_Prev : BOOL;
END_VAR

(* Rising edge detection for ingredient arrival *)
IF IngredientsDetected AND NOT IngredientsDetected_Prev THEN
    MixingInProgress := TRUE;
    MixingTimeElapsed := T#0S;
END_IF;

(* Stop conditions: ingredients removed OR time limit reached *)
IF NOT IngredientsDetected OR MixingTimeElapsed >= MixingTimeLimit THEN
    MixingInProgress := FALSE;
END_IF;

(* Timer increment only while mixing is active *)
IF MixingInProgress THEN
    MixingTimeElapsed := MixingTimeElapsed + T#1S;
END_IF;

(* Store previous state for edge detection *)
IngredientsDetected_Prev := IngredientsDetected;

END_FUNCTION_BLOCK;