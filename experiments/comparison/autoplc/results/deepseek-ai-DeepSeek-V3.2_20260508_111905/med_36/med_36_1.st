TYPE POINT :
STRUCT
    X : INT;
    Y : INT;
END_STRUCT
END_TYPE

FUNCTION_BLOCK FB_ExpandedPoint
    VAR_INPUT
        INPUT_VAR2 : INT;
        INPUT_VAR1_X : INT;
        INPUT_VAR1_Y : INT;
        INPUT_VAR3_X : INT := 1;
        INPUT_VAR3_Y : INT := 2;
    END_VAR
    
    VAR_OUTPUT
        OUTPUT_VAR2 : INT;
        OUTPUT_VAR1_X : INT;
        OUTPUT_VAR1_Y : INT;
        OUTPUT_VAR3_X : INT;
        OUTPUT_VAR3_Y : INT;
    END_VAR
    
    VAR
        VAR2 : INT;
    END_VAR

    // Assign INPUT_VAR2 to internal VAR2
    VAR2 := INPUT_VAR2;
    
    // Assign VAR2 to OUTPUT_VAR2
    OUTPUT_VAR2 := VAR2;
    
    // Assign input values to corresponding outputs
    OUTPUT_VAR1_X := INPUT_VAR1_X;
    OUTPUT_VAR1_Y := INPUT_VAR1_Y;
    OUTPUT_VAR3_X := INPUT_VAR3_X;
    OUTPUT_VAR3_Y := INPUT_VAR3_Y;
    
END_FUNCTION_BLOCK