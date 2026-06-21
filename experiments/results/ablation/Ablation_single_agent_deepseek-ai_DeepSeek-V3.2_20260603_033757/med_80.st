FUNCTION_BLOCK DoughMixerControl
VAR_INPUT
    IngredientsDetected : BOOL; (* Signal indicating presence of ingredients *)
END_VAR
VAR_OUTPUT
    MixingInProgress : BOOL; (* Control signal for mixer motor *)
END_VAR
VAR
    MixingTimeElapsed : TIME; (* Current elapsed mixing time *)
    MixingTimeLimit : TIME := T#5S; (* Configurable mixing time limit *)
    PrevIngredientsDetected : BOOL; (* Previous state for edge detection *)
END_VAR

(* Main control logic *)
IF IngredientsDetected AND NOT PrevIngredientsDetected THEN
    (* Rising edge detected - start new mixing cycle *)
    MixingTimeElapsed := T#0S;
    MixingInProgress := TRUE;
ELSIF NOT IngredientsDetected OR MixingTimeElapsed >= MixingTimeLimit THEN
    (* Stop mixing if ingredients removed or time limit reached *)
    MixingInProgress := FALSE;
END_IF

(* Timer increment logic - only while mixing is active *)
IF MixingInProgress THEN
    MixingTimeElapsed := MixingTimeElapsed + T#1S;
END_IF

(* Store current state for next cycle's edge detection *)
PrevIngredientsDetected := IngredientsDetected;
END_FUNCTION_BLOCK