ructured-text
START_ST
FUNCTION_BLOCK FB_Sum
VAR_INPUT
    maxValue : INT; // Input variable for the maximum value
END_VAR
VAR_OUTPUT
    wData : WORD; // Output variable for the sum
END_VAR
VAR
    II : INT; // Loop index variable
    state : INT; // State variable to track the current state
END_VAR

// State machine logic
state := 0; // Initialize state

CASE state OF
    0: // INITIALIZE STATE
        wData := 0; // Set wData to 0
        state := 1; // Transition to SUMMING STATE

    1: // SUMMING STATE
        FOR II := 0 TO maxValue DO
            wData := wData + II; // Increment wData by the loop index
        END_FOR;
        state := 0; // Transition back to INITIALIZE STATE
END_CASE

END_FUNCTION_BLOCK
END_ST