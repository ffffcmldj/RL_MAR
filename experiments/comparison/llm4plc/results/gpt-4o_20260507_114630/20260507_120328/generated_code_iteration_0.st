pascal
START_ST
FUNCTION_BLOCK AutomatedSmoothieMaker
VAR_INPUT
    BananaAvailable : BOOL;
    BerryMixAvailable : BOOL;
    SpinachAvailable : BOOL;
    YogurtAvailable : BOOL;
    CustomerPreference : INT;
END_VAR

VAR_OUTPUT
    BlenderMotor : BOOL;
    Dispenser : BOOL;
END_VAR

VAR
    state : INT := 0; // Current state of the FSM
    prevState : INT := 0; // Previous state for debugging or state transitions
    timer : TIME := T#0S; // Timer for dispensing or blending operations
    recipeValid : BOOL := FALSE; // Indicates whether the selected recipe is valid
    ingredientsAvailable : BOOL := FALSE; // Indicates whether all required ingredients are available
    requiredBanana : BOOL := FALSE; // Flag for Banana requirement
    requiredBerryMix : BOOL := FALSE; // Flag for Berry Mix requirement
    requiredSpinach : BOOL := FALSE; // Flag for Spinach requirement
    requiredYogurt : BOOL := FALSE; // Flag for Yogurt requirement
END_VAR

// Main logic
CASE state OF
    // STATE 0: IDLE
    0:
        BlenderMotor := FALSE;
        Dispenser := FALSE;
        recipeValid := (CustomerPreference = 1) OR (CustomerPreference = 2) OR (CustomerPreference = 3);
        IF recipeValid THEN
            state := 1; // Transition to CHECK_AVAILABILITY
        END_IF;

    // STATE 1: CHECK_AVAILABILITY
    1:
        // Determine required ingredients based on CustomerPreference
        CASE CustomerPreference OF
            1: // Recipe 1: Banana, Berry Mix, Yogurt
                requiredBanana := TRUE;
                requiredBerryMix := TRUE;
                requiredSpinach := FALSE;
                requiredYogurt := TRUE;
            2: // Recipe 2: Berry Mix, Spinach, Yogurt
                requiredBanana := FALSE;
                requiredBerryMix := TRUE;
                requiredSpinach := TRUE;
                requiredYogurt := TRUE;
            3: // Recipe 3: Banana, Spinach, Yogurt
                requiredBanana := TRUE;
                requiredBerryMix := FALSE;
                requiredSpinach := TRUE;
                requiredYogurt := TRUE;
        ELSE
            requiredBanana := FALSE;
            requiredBerryMix := FALSE;
            requiredSpinach := FALSE;
            requiredYogurt := FALSE;
        END_CASE;

        // Check ingredient availability
        ingredientsAvailable := TRUE;
        IF requiredBanana AND NOT BananaAvailable THEN
            ingredientsAvailable := FALSE;
        END_IF;
        IF requiredBerryMix AND NOT BerryMixAvailable THEN
            ingredientsAvailable := FALSE;
        END_IF;
        IF requiredSpinach AND NOT SpinachAvailable THEN
            ingredientsAvailable := FALSE;
        END_IF;
        IF requiredYogurt AND NOT YogurtAvailable THEN
            ingredientsAvailable := FALSE;
        END_IF;

        // Transition to next state
        IF ingredientsAvailable THEN
            state := 2; // Transition to DISPENSE_INGREDIENTS
        ELSE
            state := 4; // Transition to ERROR
        END_IF;

    // STATE 2: DISPENSE_INGREDIENTS
    2:
        Dispenser := TRUE;
        BlenderMotor := FALSE;

        // Simulate dispensing duration
        IF timer < T#5S THEN
            timer := timer + T#100MS; // Increment timer
        ELSE
            timer := T#0S; // Reset timer
            state := 3; // Transition to BLEND
        END_IF;

    // STATE 3: BLEND
    3:
        Dispenser := FALSE;
        BlenderMotor := TRUE;

        // Simulate blending duration
        IF timer < T#10S THEN
            timer := timer + T#100MS; // Increment timer
        ELSE
            timer := T#0S; // Reset timer
            state := 0; // Transition to IDLE
        END_IF;

    // STATE 4: ERROR
    4:
        BlenderMotor := FALSE;
        Dispenser := FALSE;

        // Wait for valid CustomerPreference to reset
        IF NOT recipeValid THEN
            recipeValid := (CustomerPreference = 1) OR (CustomerPreference = 2) OR (CustomerPreference = 3);
        END_IF;
        IF recipeValid THEN
            state := 0; // Transition to IDLE
        END_IF;

ELSE
    // Default case: Reset to IDLE state
    state := 0;
END_CASE;
END_FUNCTION_BLOCK
END_ST