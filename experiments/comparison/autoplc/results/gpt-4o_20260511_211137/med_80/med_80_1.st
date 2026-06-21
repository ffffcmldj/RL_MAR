FUNCTION_BLOCK DoughMixerControl
    VAR
        IngredientsDetected : BOOL; (* Input for detecting the presence of ingredients *)
        MixingInProgress : BOOL; (* Output for controlling the mixing process - on/off *)
        MixingTimeElapsed : TIME; (* Timer to track the mixing time *)
        MixingTimeLimit : TIME := T#5S; (* Mixing time limit - 5 seconds *)
        PreviousIngredientsDetected : BOOL := FALSE; (* Internal variable to track previous state of IngredientsDetected *)
    END_VAR

    (* Initialization *)
    MixingInProgress := FALSE;
    MixingTimeElapsed := T#0S;

    (* Control Logic *)
    IF IngredientsDetected AND NOT PreviousIngredientsDetected THEN
        (* Transition from Idle to Mixing *)
        MixingInProgress := TRUE;
        MixingTimeElapsed := T#0S;
    END_IF

    IF MixingInProgress THEN
        (* Increment MixingTimeElapsed by T#1S in each PLC scan cycle *)
        MixingTimeElapsed := MixingTimeElapsed + T#1S;

        (* Check if MixingTimeElapsed has reached MixingTimeLimit *)
        IF MixingTimeElapsed >= MixingTimeLimit THEN
            MixingInProgress := FALSE;
        END_IF

        (* Check if IngredientsDetected becomes FALSE *)
        IF NOT IngredientsDetected THEN
            MixingInProgress := FALSE;
        END_IF
    END_IF

    (* Update PreviousIngredientsDetected for next cycle *)
    PreviousIngredientsDetected := IngredientsDetected;
END_FUNCTION_BLOCK