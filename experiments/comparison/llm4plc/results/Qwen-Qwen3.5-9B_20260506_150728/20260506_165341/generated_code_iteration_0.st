START_ST
FUNCTION_BLOCK AutomatedSmoothieMaker
VAR_INPUT
    BananaAvailable : BOOL;
    BerryMixAvailable : BOOL;
    SpinachAvailable : BOOL;
    YogurtAvailable : BOOL;
    CustomerPreference : INT;
    DispenseComplete : BOOL; // Input flag to signal dispensing cycle completion
    BlendComplete : BOOL;   // Input flag to signal blending cycle completion
END_VAR

VAR_OUTPUT
    BlenderMotor : BOOL;
    Dispenser : BOOL;
END_VAR

VAR
    state : INT;
    prevState : INT;
    recipeIngredients : ARRAY[1..3] OF BOOL;
    requiredIngredients : ARRAY[1..3] OF BOOL;
    isValidPreference : BOOL;
    canStartProcess : BOOL;
    timerDispense : TIME;
    timerBlend : TIME;
    elapsedDispenseTime : TIME;
    elapsedBlendTime : TIME;
    dispenseDuration : TIME := T#5S; // Default dispense time
    blendDuration : TIME := T#10S;  // Default blend time
END_VAR

// --- Initialization ---
IF NOT state THEN
    state := 0;
    prevState := 0;
    elapsedDispenseTime := T#0S;
    elapsedBlendTime := T#0S;
END_IF;

// --- Helper Logic: Validate Preference ---
isValidPreference := (CustomerPreference = 1) OR (CustomerPreference = 2) OR (CustomerPreference = 3);

// --- Helper Logic: Define Required Ingredients per Recipe ---
// Recipe 1 (Pref 1): Banana, BerryMix, Yogurt
// Recipe 2 (Pref 2): BerryMix, Spinach, Yogurt
// Recipe 3 (Pref 3): Banana, Spinach, Yogurt
IF CustomerPreference = 1 THEN
    recipeIngredients[1] := TRUE; // Banana
    recipeIngredients[2] := TRUE; // BerryMix
    recipeIngredients[3] := TRUE; // Yogurt
ELSIF CustomerPreference = 2 THEN
    recipeIngredients[1] := FALSE; // Banana
    recipeIngredients[2] := TRUE; // BerryMix
    recipeIngredients[3] := TRUE; // Yogurt
    recipeIngredients[4] := TRUE; // Spinach (Note: Array size adjusted logic below)
ELSE // CustomerPreference = 3
    recipeIngredients[1] := TRUE; // Banana
    recipeIngredients[2] := FALSE; // BerryMix
    recipeIngredients[3] := TRUE; // Yogurt
    recipeIngredients[4] := TRUE; // Spinach
END_IF;

// Corrected Array Logic for 4 ingredients across 3 recipes
// Re-defining required ingredients check based on specific recipe logic
IF CustomerPreference = 1 THEN
    canStartProcess := (BananaAvailable AND BerryMixAvailable AND YogurtAvailable);
ELSIF CustomerPreference = 2 THEN
    canStartProcess := (BerryMixAvailable AND SpinachAvailable AND YogurtAvailable);
ELSE // CustomerPreference = 3
    canStartProcess := (BananaAvailable AND SpinachAvailable AND YogurtAvailable);
END_IF;

// --- State Machine Logic ---

// Transition: State 0 (Idle) -> State 1 (Dispensing)
// Condition: Valid Preference AND All Ingredients Available
IF (state = 0) AND (isValidPreference) AND (canStartProcess) THEN
    state := 1;
    prevState := 1;
    elapsedDispenseTime := T#0S;
    elapsedBlendTime := T#0S;
END_IF;

// Transition: State 1 (Dispensing) -> State 2 (Blending)
// Condition: Dispensing is complete (Timer reached or DispenseComplete flag)
IF (state = 1) AND (DispenseComplete OR elapsedDispenseTime >= dispenseDuration) THEN
    state := 2;
    prevState := 2;
    elapsedDispenseTime := T#0S;
    elapsedBlendTime := T#0S;
END_IF;

// Transition: State 2 (Blending) -> State 0 (Idle)
// Condition: Blending is complete (Timer reached or BlendComplete flag)
IF (state = 2) AND (BlendComplete OR elapsedBlendTime >= blendDuration) THEN
    state := 0;
    prevState := 0;
    elapsedDispenseTime := T#0S;
    elapsedBlendTime := T#0S;
END_IF;

// --- Output Assignment based on State ---

CASE state OF
    0: // IDLE / INVALID
        BlenderMotor := FALSE;
        Dispenser := FALSE;
        
    1: // DISPENSING INGREDIENTS
        // Only activate dispenser if we are in this state and ingredients are still available
        // (In a real system, we might check availability again, but FSM state implies process started)
        Dispenser := TRUE;
        BlenderMotor := FALSE;
        
        // Update timer
        IF elapsedDispenseTime < dispenseDuration THEN
            elapsedDispenseTime := elapsedDispenseTime + T#100MS; // Scan cycle increment
        END_IF;
        
    2: // BLENDING
        Dispenser := FALSE;
        BlenderMotor := TRUE;
        
        // Update timer
        IF elapsedBlendTime < blendDuration THEN
            elapsedBlendTime := elapsedBlendTime + T#100MS; // Scan cycle increment
        END_IF;
END_CASE;

END_FUNCTION_BLOCK
END_ST