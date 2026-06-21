FUNCTION_BLOCK FB_ValueOut
VAR_INPUT
    valueIn : INT; // The input value to be processed
    conf : UINT;   // Configuration setting, range 1-10
END_VAR

VAR
    ValueOut : INT; // The processed output value
END_VAR

// Initialization of ValueOut
ValueOut := 0;

// Input Validation
IF (conf < 1) OR (conf > 10) THEN
    ValueOut := 0; // Set ValueOut to 0 if conf is out of range
ELSE
    // Processing Logic
    CASE conf OF
        1, 2:
            ValueOut := valueIn / 10; // Divide valueIn by 10
        3:
            IF valueIn = 0 THEN
                ValueOut := 0;
            ELSIF valueIn = 300 THEN
                ValueOut := 163;
            ELSIF valueIn = 600 THEN
                ValueOut := 331;
            ELSE
                ValueOut := 0; // For any other valueIn
            END_IF;
        6, 7:
            IF valueIn = 100 THEN
                ValueOut := 319;
            ELSE
                ValueOut := 0; // For any other valueIn
            END_IF;
        4, 5, 8, 9, 10:
            ValueOut := 0; // Set ValueOut to 0 for these conf values
        ELSE
            ValueOut := 0; // Default case
    END_CASE;
END_IF;

// Ensure ValueOut is non-negative
IF ValueOut < 0 THEN
    ValueOut := 0;
END_IF;

END_FUNCTION_BLOCK