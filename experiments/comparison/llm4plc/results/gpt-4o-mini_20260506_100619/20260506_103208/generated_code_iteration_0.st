ructured-text
START_ST
FUNCTION_BLOCK FB_FactorialCalculator
    VAR_INPUT
        X : INT; // Input integer
    END_VAR

    VAR_OUTPUT
        FactorialResult : INT; // Output for factorial result
        FactorialGoodResult : INT; // Output for factorial good result
    END_VAR

    // State variable to track the current state
    VAR
        state: INT := 0; // Initialize state to 0
    END_VAR

    // State machine logic
    CASE state OF
        0: // INITIALIZE
            FactorialResult := 1;
            FactorialGoodResult := 1;
            state := 1; // Transition to CHECK INPUT RANGE

        1: // CHECK INPUT RANGE
            IF (X >= -3) AND (X <= 3) THEN
                state := 2; // Transition to CALCULATE FACTORIAL GOOD RESULT
            ELSE
                state := 4; // Transition to HANDLE OVERFLOW
            END_IF;

        2: // CALCULATE FACTORIAL GOOD RESULT
            FactorialGoodResult := X * X * X * X; // Calculate X^4
            state := 3; // Transition to CALCULATE FACTORIAL RESULT

        3: // CALCULATE FACTORIAL RESULT
            IF FactorialGoodResult > 1 THEN
                FactorialResult := FactorialGoodResult * (FactorialGoodResult - 1); // Calculate factorial result
            ELSE
                FactorialResult := FactorialGoodResult; // Set to FactorialGoodResult
            END_IF;
            state := 0; // Transition back to INITIALIZE

        4: // HANDLE OVERFLOW
            FactorialResult := 1; // Prevent overflow
            FactorialGoodResult := 1; // Prevent overflow
            state := 0; // Transition back to INITIALIZE
    END_CASE

END_FUNCTION_BLOCK
END_ST