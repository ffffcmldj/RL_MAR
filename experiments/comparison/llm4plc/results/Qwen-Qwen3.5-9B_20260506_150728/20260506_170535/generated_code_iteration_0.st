START_ST
FUNCTION_BLOCK FB_Sum
VAR_INPUT
    maxValue : INT;
END_VAR
VAR_OUTPUT
    wData : WORD;
END_VAR
VAR
    II : INT;
    currentState : INT;
END_VAR

// STATE 0: INITIALIZE_OUTPUT
// Action: Reset accumulator and prepare loop counter
IF currentState = 0 THEN
    wData := 0;
    II := 0;
    currentState := 1;
END_IF;

// STATE 1: EXECUTE_SUMMATION_LOOP
// Action: Accumulate sum based on loop index
IF currentState = 1 THEN
    IF II <= maxValue THEN
        wData := wData + II;
        II := II + 1;
        // Transition back to State 1 if loop continues
        // Transition to State 2 if loop is done
        IF II > maxValue THEN
            currentState := 2;
        END_IF;
    END_IF;
END_IF;

// STATE 2: FINALIZE_OUTPUT
// Action: Hold final result
IF currentState = 2 THEN
    // wData holds the final result
    // II holds the value (maxValue + 1)
    // Logic execution complete for this cycle
END_IF;

END_FUNCTION_BLOCK
END_ST