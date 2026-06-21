FUNCTION_BLOCK DoughMixerControl
VAR_INPUT
    IngredientsDetected : BOOL; (* Input for detecting the presence of ingredients *)
END_VAR

VAR_OUTPUT
    MixingInProgress : BOOL; (* Output for controlling the mixing process - on/off *)
END_VAR

VAR
    MixingTimeElapsed : TIME; (* Timer to track the mixing time *)
    MixingTimeLimit : TIME := T#5S; (* Mixing time limit - 5 seconds *)
    PrevIngredientsDetected : BOOL; (* Previous state for edge detection *)
END_VAR

(* Main execution logic *)
IF NOT PrevIngredientsDetected AND IngredientsDetected THEN
    (* Rising edge detected - start new mixing cycle *)
    MixingInProgress := TRUE;
    MixingTimeElapsed := T#0S;
ELSIF MixingInProgress THEN
    (* Mixing is in progress *)
    IF MixingTimeElapsed >= MixingTimeLimit OR NOT IngredientsDetected THEN
        (* Stop conditions: time limit reached or ingredients no longer detected *)
        MixingInProgress := FALSE;
    ELSE
        (* Increment timer by 1 second per scan cycle *)
        MixingTimeElapsed := MixingTimeElapsed + T#1S;
    END_IF;
END_IF;

(* Store current state for next edge detection *)
PrevIngredientsDetected := IngredientsDetected;

END_FUNCTION_BLOCK