START_ST
FUNCTION_BLOCK FB_SimpleCalculation
VAR_INPUT
    INPUT_VAR1 : INT := 2;
    VAR2 : INT := 0;
END_VAR

VAR_OUTPUT
    OUTPUT_VAR1 : INT;
    OUTPUT_VAR2 : INT;
END_VAR

VAR
    state : INT;
    COUNTER2 : INT := 0;
    iteration_count : INT := 0;
    TEMP_OUTPUT_VAR1 : INT;
    TEMP_OUTPUT_VAR2 : INT;
END_VAR

END_VAR

CASE state OF
    0: // STATE 0: INITIALIZE
        OUTPUT_VAR1 := INPUT_VAR1;
        OUTPUT_VAR2 := VAR2;
        COUNTER2 := 0;
        iteration_count := 0;
        state := 1;
        
    1: // STATE 1: MULTIPLY_LOOP
        TEMP_OUTPUT_VAR1 := OUTPUT_VAR1 * 2;
        OUTPUT_VAR1 := TEMP_OUTPUT_VAR1;
        COUNTER2 := COUNTER2 + 1;
        
        IF COUNTER2 >= 5 THEN
            state := 2;
        END_IF;
        
    2: // STATE 2: INCREMENT_LOOP
        TEMP_OUTPUT_VAR2 := OUTPUT_VAR2 + 1;
        OUTPUT_VAR2 := TEMP_OUTPUT_VAR2;
        iteration_count := iteration_count + 1;
        
        IF iteration_count >= 5 THEN
            state := 3;
        END_IF;
        
    3: // STATE 3: FINALIZE
        // Results are already stored in OUTPUT_VAR1 and OUTPUT_VAR2 from previous states.
        // COUNTER2 holds the value 5 from the completion of State 1.
        // No further action required for this specific logic flow.
        // State remains here or transitions to 0 based on external reset logic not specified.
        // Keeping state at 3 to hold final values.
END_CASE

END_FUNCTION_BLOCK
END_ST