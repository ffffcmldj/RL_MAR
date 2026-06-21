ructured-text
START_ST
FUNCTION_BLOCK FB_ValueOut
VAR_INPUT
    valueIn : INT; // The input value to be processed
    conf : UINT; // Configuration setting, range 1-10
END_VAR
VAR
    ValueOut : INT; // The processed output value
END_VAR

// Initialize ValueOut
ValueOut := 0;

// Process the input value based on the configuration
CASE conf OF
    1, 2: 
        ValueOut := valueIn / 10; // Divide valueIn by 10
    3: 
        CASE valueIn OF
            0: ValueOut := 0; // If valueIn is 0
            300: ValueOut := 163; // If valueIn is 300
            600: ValueOut := 331; // If valueIn is 600
            ELSE: ValueOut := 0; // For any other valueIn
        END_CASE;
    6, 7: 
        CASE valueIn OF
            100: ValueOut := 319; // If valueIn is 100
            ELSE: ValueOut := 0; // For any other valueIn
        END_CASE;
    4, 5, 8, 9, 10, 
    ELSE: 
        ValueOut := 0; // Set ValueOut to 0
END_CASE;

END_FUNCTION_BLOCK
END_ST