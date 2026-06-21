ructured-text
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
    state : INT; // THE STATE VARIABLE
    prevState : INT; // THE PREVIOUS STATE VARIABLE
END_VAR

// State Definitions
state := 0; // Initialize state

// State Machine
CASE state OF
    0: // INITIALIZE
        BlenderMotor := FALSE;
        Dispenser := FALSE;
        state := 1; // Transition to CHECK INGREDIENTS

    1: // CHECK INGREDIENTS
        IF (CustomerPreference = 1) AND BananaAvailable AND BerryMixAvailable AND YogurtAvailable THEN
            state := 2; // Transition to PREPARE SMOOTHIE RECIPE 1
        ELSIF (CustomerPreference = 2) AND BerryMixAvailable AND SpinachAvailable AND YogurtAvailable THEN
            state := 3; // Transition to PREPARE SMOOTHIE RECIPE 2
        ELSIF (CustomerPreference = 3) AND BananaAvailable AND SpinachAvailable AND YogurtAvailable THEN
            state := 4; // Transition to PREPARE SMOOTHIE RECIPE 3
        ELSE
            state := 5; // Transition to INVALID PREFERENCE OR INGREDIENT UNAVAILABLE
        END_IF;

    2: // PREPARE SMOOTHIE RECIPE 1
        BlenderMotor := TRUE;
        Dispenser := TRUE; // Dispense Banana, Berry Mix, Yogurt
        // Add logic for blending duration if needed
        state := 1; // Return to CHECK INGREDIENTS after preparation

    3: // PREPARE SMOOTHIE RECIPE 2
        BlenderMotor := TRUE;
        Dispenser := TRUE; // Dispense Berry Mix, Spinach, Yogurt
        // Add logic for blending duration if needed
        state := 1; // Return to CHECK INGREDIENTS after preparation

    4: // PREPARE SMOOTHIE RECIPE 3
        BlenderMotor := TRUE;
        Dispenser := TRUE; // Dispense Banana, Spinach, Yogurt
        // Add logic for blending duration if needed
        state := 1; // Return to CHECK INGREDIENTS after preparation

    5: // INVALID PREFERENCE OR INGREDIENT UNAVAILABLE
        BlenderMotor := FALSE;
        Dispenser := FALSE;
        // Remain in this state until reset or re-initialized
END_CASE;

END_FUNCTION_BLOCK
END_ST