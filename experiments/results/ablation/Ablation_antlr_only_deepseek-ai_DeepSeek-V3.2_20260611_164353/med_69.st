TYPE
    // Enumeration for configuration settings to improve code readability
    ConfSetting : (
        CONF_1 := 1,
        CONF_2 := 2,
        CONF_3 := 3,
        CONF_4 := 4,
        CONF_5 := 5,
        CONF_6 := 6,
        CONF_7 := 7,
        CONF_8 := 8,
        CONF_9 := 9,
        CONF_10 := 10
    ) UINT;
END_TYPE

FUNCTION_BLOCK FB_ValueOut
VAR_INPUT
    valueIn : INT;
    conf : UINT;
END_VAR

VAR_OUTPUT
    ValueOut : INT;
END_VAR

VAR
    // Temporary variable for intermediate calculations
    tempResult : INT;
END_VAR

// Main processing logic
CASE conf OF
    1, 2: // Configuration 1 or 2: Divide valueIn by 10
        tempResult := valueIn / 10;
        IF tempResult < 0 THEN
            ValueOut := 0; // Ensure non-negative output
        ELSE
            ValueOut := tempResult;
        END_IF;
        
    3: // Configuration 3: Specific value mappings
        IF valueIn = 0 THEN
            ValueOut := 0;
        ELSIF valueIn = 300 THEN
            ValueOut := 163;
        ELSIF valueIn = 600 THEN
            ValueOut := 331;
        ELSE
            ValueOut := 0;
        END_IF;
        
    6, 7: // Configuration 6 or 7: Specific value mapping
        IF valueIn = 100 THEN
            ValueOut := 319;
        ELSE
            ValueOut := 0;
        END_IF;
        
    ELSE // All other configurations (4, 5, 8, 9, 10, and any other value)
        ValueOut := 0;
END_CASE;

END_FUNCTION_BLOCK;