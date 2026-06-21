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
    // State management
    CurrentState : INT := 0;  // 0=Idle, 1=IngredientValidation, 2=Dispensing, 3=Blending, 4=FaultInvalid
    NextState : INT;
    
    // Recipe validation flags
    RecipeValid : BOOL;
    AllIngredientsAvailable : BOOL;
    
    // Timer variables for dispensing and blending durations
    DispensingTimer : TON;
    BlendingTimer : TON;
    
    // Timer preset values (in milliseconds)
    DispensingTime : TIME := T#5S;  // 5 seconds for dispensing
    BlendingTime : TIME := T#10S;   // 10 seconds for blending
    
    // Internal flags for state transitions
    StartDispensing : BOOL;
    StartBlending : BOOL;
    
    // Loop variable
    i : INT;
END_VAR

// Initialize timers
DispensingTimer(IN:=FALSE, PT:=DispensingTime);
BlendingTimer(IN:=FALSE, PT:=BlendingTime);

// Default next state is current state
NextState := CurrentState;

// State machine implementation
CASE CurrentState OF
    0: // Idle State
        BlenderMotor := FALSE;
        Dispenser := FALSE;
        StartDispensing := FALSE;
        StartBlending := FALSE;
        
        // Reset timers
        DispensingTimer(IN:=FALSE);
        BlendingTimer(IN:=FALSE);
        
        // Check if valid customer preference is received
        IF (CustomerPreference >= 1) AND (CustomerPreference <= 3) THEN
            NextState := 1; // Transition to IngredientValidation
        ELSE
            NextState := 4; // Transition to FaultInvalid for invalid preference
        END_IF;
        
    1: // Ingredient Validation State
        BlenderMotor := FALSE;
        Dispenser := FALSE;
        StartDispensing := FALSE;
        StartBlending := FALSE;
        
        // Check recipe based on customer preference
        RecipeValid := TRUE;
        AllIngredientsAvailable := TRUE;
        
        CASE CustomerPreference OF
            1: // Recipe 1: Banana, Berry Mix, Yogurt
                IF NOT BananaAvailable THEN
                    AllIngredientsAvailable := FALSE;
                END_IF;
                IF NOT BerryMixAvailable THEN
                    AllIngredientsAvailable := FALSE;
                END_IF;
                IF NOT YogurtAvailable THEN
                    AllIngredientsAvailable := FALSE;
                END_IF;
                
            2: // Recipe 2: Berry Mix, Spinach, Yogurt
                IF NOT BerryMixAvailable THEN
                    AllIngredientsAvailable := FALSE;
                END_IF;
                IF NOT SpinachAvailable THEN
                    AllIngredientsAvailable := FALSE;
                END_IF;
                IF NOT YogurtAvailable THEN
                    AllIngredientsAvailable := FALSE;
                END_IF;
                
            3: // Recipe 3: Banana, Spinach, Yogurt
                IF NOT BananaAvailable THEN
                    AllIngredientsAvailable := FALSE;
                END_IF;
                IF NOT SpinachAvailable THEN
                    AllIngredientsAvailable := FALSE;
                END_IF;
                IF NOT YogurtAvailable THEN
                    AllIngredientsAvailable := FALSE;
                END_IF;
                
            ELSE
                RecipeValid := FALSE;
        END_CASE;
        
        // Determine next state based on validation
        IF RecipeValid AND AllIngredientsAvailable THEN
            NextState := 2; // Transition to Dispensing
            StartDispensing := TRUE;
        ELSE
            NextState := 4; // Transition to FaultInvalid
        END_IF;
        
    2: // Dispensing State
        Dispenser := TRUE;
        BlenderMotor := FALSE;
        StartBlending := FALSE;
        
        // Start dispensing timer if just entered this state
        IF StartDispensing THEN
            DispensingTimer(IN:=TRUE);
            StartDispensing := FALSE;
        END_IF;
        
        // Check if dispensing timer has elapsed
        DispensingTimer(IN:=TRUE);
        IF DispensingTimer.Q THEN
            NextState := 3; // Transition to Blending
            StartBlending := TRUE;
            DispensingTimer(IN:=FALSE);
        ELSE
            NextState := 2; // Stay in Dispensing
        END_IF;
        
    3: // Blending State
        BlenderMotor := TRUE;
        Dispenser := FALSE;
        
        // Start blending timer if just entered this state
        IF StartBlending THEN
            BlendingTimer(IN:=TRUE);
            StartBlending := FALSE;
        END_IF;
        
        // Check if blending timer has elapsed
        BlendingTimer(IN:=TRUE);
        IF BlendingTimer.Q THEN
            NextState := 0; // Transition back to Idle
            BlendingTimer(IN:=FALSE);
        ELSE
            NextState := 3; // Stay in Blending
        END_IF;
        
    4: // Fault/Invalid State
        BlenderMotor := FALSE;
        Dispenser := FALSE;
        StartDispensing := FALSE;
        StartBlending := FALSE;
        
        // Reset timers
        DispensingTimer(IN:=FALSE);
        BlendingTimer(IN:=FALSE);
        
        // Check if a new valid customer preference is received
        IF (CustomerPreference >= 1) AND (CustomerPreference <= 3) THEN
            NextState := 1; // Transition to IngredientValidation
        ELSE
            NextState := 4; // Stay in FaultInvalid
        END_IF;
        
END_CASE;

// Update current state for next cycle
CurrentState := NextState;

END_FUNCTION_BLOCK