ructured-text
FUNCTION_BLOCK DoughMixerControl
VAR_INPUT
    IngredientsDetected : BOOL; (* Input for detecting the presence of ingredients *)
END_VAR_INPUT

VAR_OUTPUT
    MixingInProgress : BOOL; (* Output for controlling the mixing process - on/off *)
END_VAR_OUTPUT

VAR
    MixingTimeElapsed : TIME; (* Timer to track the mixing time *)
    MixingTimeLimit : TIME := T#5S; (* Mixing time limit - 5 seconds *)
    prevIngredientsDetected : BOOL; (* To track the previous state of IngredientsDetected *)
END_VAR

(* Function Block Logic *)
IF IngredientsDetected AND NOT prevIngredientsDetected THEN
    MixingInProgress := TRUE; (* Start mixing *)
    MixingTimeElapsed := T#0S; (* Reset timer *)
ELSIF MixingInProgress THEN
    MixingTimeElapsed := MixingTimeElapsed + T#1S; (* Increment timer *)
    
    IF MixingTimeElapsed >= MixingTimeLimit OR NOT IngredientsDetected THEN
        MixingInProgress := FALSE; (* Stop mixing *)
    END_IF
END_IF

prevIngredientsDetected := IngredientsDetected; (* Update previous state *)
END_FUNCTION_BLOCK