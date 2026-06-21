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
    state : INT := 0;
    prevState : INT := 0;
    dispenseCounter : INT := 0;
    blendCounter : INT := 0;
    requiredIngredientsMet : BOOL;
    DISPENSE_TIME : INT := 5;
    BLEND_TIME : INT := 10;
END_VAR

    (* State Machine Execution *)
    CASE state OF
        0: (* IDLE *)
            BlenderMotor := FALSE;
            Dispenser := FALSE;
            dispenseCounter := 0;
            blendCounter := 0;

            (* Check for valid preference and required ingredients *)
            CASE CustomerPreference OF
                1: (* Recipe 1: Banana, Berry Mix, Yogurt *)
                    requiredIngredientsMet := BananaAvailable AND BerryMixAvailable AND YogurtAvailable;
                2: (* Recipe 2: Berry Mix, Spinach, Yogurt *)
                    requiredIngredientsMet := BerryMixAvailable AND SpinachAvailable AND YogurtAvailable;
                3: (* Recipe 3: Banana, Spinach, Yogurt *)
                    requiredIngredientsMet := BananaAvailable AND SpinachAvailable AND YogurtAvailable;
                ELSE
                    requiredIngredientsMet := FALSE;
            END_CASE;

            (* Transition from IDLE *)
            IF (CustomerPreference >= 1) AND (CustomerPreference <= 3) AND requiredIngredientsMet THEN
                state := 1; (* Move to DISPENSING *)
            ELSIF (CustomerPreference < 1) OR (CustomerPreference > 3) OR NOT requiredIngredientsMet THEN
                state := 3; (* Move to ERROR *)
            END_IF;

        1: (* DISPENSING *)
            BlenderMotor := FALSE;
            Dispenser := TRUE;

            (* Increment counter and check for transition to BLENDING *)
            dispenseCounter := dispenseCounter + 1;
            IF dispenseCounter >= DISPENSE_TIME THEN
                state := 2;
                dispenseCounter := 0;
            END_IF;

        2: (* BLENDING *)
            BlenderMotor := TRUE;
            Dispenser := FALSE;

            (* Increment counter and check for transition to IDLE *)
            blendCounter := blendCounter + 1;
            IF blendCounter >= BLEND_TIME THEN
                state := 0;
                blendCounter := 0;
            END_IF;

        3: (* ERROR *)
            BlenderMotor := FALSE;
            Dispenser := FALSE;

            (* Check for conditions to return to IDLE *)
            CASE CustomerPreference OF
                1:
                    requiredIngredientsMet := BananaAvailable AND BerryMixAvailable AND YogurtAvailable;
                2:
                    requiredIngredientsMet := BerryMixAvailable AND SpinachAvailable AND YogurtAvailable;
                3:
                    requiredIngredientsMet := BananaAvailable AND SpinachAvailable AND YogurtAvailable;
                ELSE
                    requiredIngredientsMet := FALSE;
            END_CASE;

            IF (CustomerPreference >= 1) AND (CustomerPreference <= 3) AND requiredIngredientsMet THEN
                state := 0;
            END_IF;

    END_CASE;

    (* Store previous state for potential future use, though not directly used in transitions here *)
    prevState := state;

END_FUNCTION_BLOCK
END_ST