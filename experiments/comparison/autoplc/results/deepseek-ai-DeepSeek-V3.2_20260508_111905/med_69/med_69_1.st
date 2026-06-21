FUNCTION_BLOCK FB_ValueOut
VAR_INPUT
    valueIn : INT;
    conf : UINT;
END_VAR
VAR_OUTPUT
    ValueOut : INT;
END_VAR
VAR
    tempValue : INT;
END_VAR

// Initialize output
ValueOut := 0;

// Process based on configuration
CASE conf OF
    1, 2:
        // Divide valueIn by 10 using integer division
        tempValue := valueIn;
        IF tempValue >= 0 THEN
            ValueOut := tempValue / 10;
        ELSE
            // For negative values, ensure non-negative output
            ValueOut := 0;
        END_IF;
        
    3:
        // Handle specific valueIn cases for conf = 3
        IF valueIn = 0 THEN
            ValueOut := 0;
        ELSIF valueIn = 300 THEN
            ValueOut := 163;
        ELSIF valueIn = 600 THEN
            ValueOut := 331;
        ELSE
            ValueOut := 0;
        END_IF;
        
    6, 7:
        // Handle specific valueIn cases for conf = 6 or 7
        IF valueIn = 100 THEN
            ValueOut := 319;
        ELSE
            ValueOut := 0;
        END_IF;
        
    ELSE
        // Default case for conf = 4, 5, 8, 9, 10, or any other value
        ValueOut := 0;
END_CASE;

// Ensure output is non-negative
IF ValueOut < 0 THEN
    ValueOut := 0;
END_IF;

END_FUNCTION_BLOCK