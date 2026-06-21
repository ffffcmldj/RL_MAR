TYPE
    ST_ValueMapping : STRUCT
        valueInCondition : INT;
        valueOutResult : INT;
    END_STRUCT
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
    // Local variable for intermediate calculation
    tempResult : INT;
    // Array for conf=3 specific mappings
    conf3Mappings : ARRAY[1..3] OF ST_ValueMapping := [
        (valueInCondition := 0, valueOutResult := 0),
        (valueInCondition := 300, valueOutResult := 163),
        (valueInCondition := 600, valueOutResult := 331)
    ];
    // Array for conf=6/7 specific mapping
    conf67Mappings : ARRAY[1..1] OF ST_ValueMapping := [
        (valueInCondition := 100, valueOutResult := 319)
    ];
    i : INT;
    mappingFound : BOOL;
END_VAR

// Initialize output to 0
ValueOut := 0;

// Process based on configuration
CASE conf OF
    1, 2: // Divide valueIn by 10
        tempResult := valueIn / 10;
        // Ensure non-negative result
        IF tempResult >= 0 THEN
            ValueOut := tempResult;
        ELSE
            ValueOut := 0;
        END_IF;
        
    3: // Specific mappings for conf=3
        mappingFound := FALSE;
        FOR i := 1 TO 3 DO
            IF valueIn = conf3Mappings[i].valueInCondition THEN
                ValueOut := conf3Mappings[i].valueOutResult;
                mappingFound := TRUE;
                EXIT;
            END_IF;
        END_FOR;
        
        // If no mapping found, set to 0
        IF NOT mappingFound THEN
            ValueOut := 0;
        END_IF;
        
    6, 7: // Specific mapping for conf=6 or 7
        IF valueIn = conf67Mappings[1].valueInCondition THEN
            ValueOut := conf67Mappings[1].valueOutResult;
        ELSE
            ValueOut := 0;
        END_IF;
        
    ELSE // All other conf values (4,5,8,9,10, and any other)
        ValueOut := 0;
END_CASE;

// Final safety check to ensure non-negative output
IF ValueOut < 0 THEN
    ValueOut := 0;
END_IF;

END_FUNCTION_BLOCK;