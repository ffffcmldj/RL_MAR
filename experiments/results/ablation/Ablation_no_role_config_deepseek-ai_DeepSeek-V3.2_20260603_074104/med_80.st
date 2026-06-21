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
    PrevIngredientsDetected : BOOL;
END_VAR

(* Rising edge detection for ingredient presence *)
IF IngredientsDetected AND NOT PrevIngredientsDetected THEN
    (* Start mixing cycle *)
    MixingInProgress := TRUE;
    MixingTimeElapsed := T#0S;
ELSIF NOT IngredientsDetected OR MixingTimeElapsed >= MixingTimeLimit THEN
    (* Stop conditions: ingredients removed or time limit reached *)
    MixingInProgress := FALSE;
END_IF;

(* Increment timer while mixing is active *)
IF MixingInProgress THEN
    MixingTimeElapsed := MixingTimeElapsed + T#1S;
END_IF;

(* Store current state for edge detection in next cycle *)
PrevIngredientsDetected := IngredientsDetected;
END_FUNCTION_BLOCK