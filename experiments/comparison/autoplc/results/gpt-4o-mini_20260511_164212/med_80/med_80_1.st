FUNCTION_BLOCK DoughMixerControl
    VAR
        IngredientsDetected : BOOL; (* Input for detecting the presence of ingredients *)
        MixingInProgress : BOOL; (* Output for controlling the mixing process - on/off *)
        MixingTimeElapsed : TIME; (* Timer to track the mixing time *)
        MixingTimeLimit : TIME := T#5S; (* Mixing time limit - 5 seconds *)
    END_VAR

    VAR
        PreviousIngredientsDetected : BOOL := FALSE; (* To track the previous state of IngredientsDetected *)
    END_VAR

    // Initialization
    IF NOT MixingInProgress THEN
        MixingTimeElapsed := T#0S; // Reset timer when not mixing
    END_IF

    // Monitor the IngredientsDetected input
    IF IngredientsDetected AND NOT PreviousIngredientsDetected THEN
        // Transition from Idle to Mixing
        MixingInProgress := TRUE; // Start mixing
        MixingTimeElapsed := T#0S; // Reset mixing time
    ELSIF NOT IngredientsDetected AND PreviousIngredientsDetected THEN
        // Transition from Mixing to Idle
        MixingInProgress := FALSE; // Stop mixing
    END_IF

    // Increment MixingTimeElapsed if mixing is in progress
    IF MixingInProgress THEN
        MixingTimeElapsed := MixingTimeElapsed + T#1S; // Increment timer by 1 second

        // Check if MixingTimeElapsed has reached MixingTimeLimit
        IF MixingTimeElapsed >= MixingTimeLimit THEN
            MixingInProgress := FALSE; // Stop mixing if time limit reached
        END_IF
    END_IF

    // Update the previous state of IngredientsDetected
    PreviousIngredientsDetected := IngredientsDetected;

END_FUNCTION_BLOCK