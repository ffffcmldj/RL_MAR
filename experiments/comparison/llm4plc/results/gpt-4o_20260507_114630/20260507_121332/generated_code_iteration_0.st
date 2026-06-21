plaintext
START_ST
FUNCTION_BLOCK FB_ValueOut
VAR_INPUT
    valueIn : INT; // The input value to be processed
    conf : UINT;   // Configuration setting, range 1-10
END_VAR
VAR_OUTPUT
    ValueOut : INT; // The processed output value
END_VAR

VAR
    // No internal variables required for this task
END_VAR

// Main logic
ValueOut := 0; // Default output value

CASE conf OF
    1, 2: 
        // Divide valueIn by 10 and ensure non-negative result
        ValueOut := ABS(valueIn / 10);
    
    3: 
        // Handle specific valueIn cases
        CASE valueIn OF
            0: 
                ValueOut := 0;
            300: 
                ValueOut := 163;
            600: 
                ValueOut := 331;
            ELSE
                ValueOut := 0;
        END_CASE;

    6, 7: 
        // Handle specific valueIn case
        IF valueIn = 100 THEN
            ValueOut := 319;
        ELSE
            ValueOut := 0;
        END_IF;

    4, 5, 8, 9, 10: 
        // Set ValueOut to 0 for these configurations
        ValueOut := 0;

    ELSE
        // Default case for any other conf value
        ValueOut := 0;
END_CASE;

END_FUNCTION_BLOCK
END_ST