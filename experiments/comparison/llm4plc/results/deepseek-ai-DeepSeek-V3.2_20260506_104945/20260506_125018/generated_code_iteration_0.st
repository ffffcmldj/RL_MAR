START_ST
FUNCTION_BLOCK DoughMixerControl
VAR_INPUT
    IngredientsDetected : BOOL;
END_VAR
VAR_OUTPUT
    MixingInProgress : BOOL;
END_VAR
VAR
    state : INT;
    prevIngredientsDetected : BOOL;
    MixingTimeElapsed : TIME;
    MixingTimeLimit : TIME := T#5S;
END_VAR

(* State definitions *)
CONSTANT
    STATE_IDLE : INT := 0;
    STATE_MIXING : INT := 1;
END_CONSTANT

(* Main execution logic *)
CASE state OF
    STATE_IDLE:
        (* Output *)
        MixingInProgress := FALSE;
        (* Timer holds value - no increment in IDLE state *)
        (* Check for rising edge to start mixing *)
        IF (IngredientsDetected AND NOT prevIngredientsDetected) THEN
            (* Reset timer and transition to MIXING state *)
            MixingTimeElapsed := T#0S;
            state := STATE_MIXING;
        END_IF;

    STATE_MIXING:
        (* Output *)
        MixingInProgress := TRUE;
        (* Increment timer by 1 second per PLC cycle *)
        MixingTimeElapsed := MixingTimeElapsed + T#1S;
        (* Check transition conditions *)
        IF (MixingTimeElapsed >= MixingTimeLimit) OR (NOT IngredientsDetected) THEN
            state := STATE_IDLE;
        END_IF;
END_CASE;

(* Update edge detection variable for next cycle *)
prevIngredientsDetected := IngredientsDetected;

END_FUNCTION_BLOCK
END_ST