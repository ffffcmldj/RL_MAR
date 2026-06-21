ructured-text
START_ST
TYPE POINT
    X: INT;
    Y: INT;
END_TYPE

FUNCTION_BLOCK FB_PointOperations
    VAR_INPUT
        INPUT_VAR2: INT := 7; // Default value
    END_VAR
    
    VAR_OUTPUT
        OUTPUT_VAR1: POINT; // Output variable of type POINT
        OUTPUT_VAR3: POINT; // Output variable of type POINT
    END_VAR
    
    VAR
        VAR2: INT; // Internal variable
    END_VAR
    
    // Assign INPUT_VAR2 to VAR2
    VAR2 := INPUT_VAR2;
    
    // Set OUTPUT_VAR1 values
    OUTPUT_VAR1.X := 1;
    OUTPUT_VAR1.Y := 2;
    
    // Set OUTPUT_VAR3 values
    OUTPUT_VAR3.X := 100;
    OUTPUT_VAR3.Y := -7000;

END_FUNCTION_BLOCK
END_ST