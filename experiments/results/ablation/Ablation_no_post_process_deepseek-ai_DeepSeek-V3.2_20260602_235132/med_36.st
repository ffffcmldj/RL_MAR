TYPE
    Point2D : STRUCT
        X : INT;
        Y : INT;
    END_STRUCT;
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
        // Internal structured variables for cleaner code organization
        Internal_INPUT_VAR1 : Point2D;
        Internal_INPUT_VAR3 : Point2D;
        Internal_OUTPUT_VAR1 : Point2D;
        Internal_OUTPUT_VAR3 : Point2D;
    END_VAR

    // Main execution logic
    OUTPUT_VAR2 := INPUT_VAR2;
    
    // Set OUTPUT_VAR1_X and OUTPUT_VAR1_Y to fixed constants as specified
    OUTPUT_VAR1_X := 1;
    OUTPUT_VAR1_Y := 2;
    
    // Set OUTPUT_VAR3_X and OUTPUT_VAR3_Y to fixed constants as specified
    OUTPUT_VAR3_X := 100;
    OUTPUT_VAR3_Y := -7000;
    
    // Optional: Update internal structured variables for consistency
    Internal_OUTPUT_VAR1.X := OUTPUT_VAR1_X;
    Internal_OUTPUT_VAR1.Y := OUTPUT_VAR1_Y;
    Internal_OUTPUT_VAR3.X := OUTPUT_VAR3_X;
    Internal_OUTPUT_VAR3.Y := OUTPUT_VAR3_Y;
    
    // Store input values in internal structured variables (for potential future use)
    Internal_INPUT_VAR1.X := INPUT_VAR1_X;
    Internal_INPUT_VAR1.Y := INPUT_VAR1_Y;
    Internal_INPUT_VAR3.X := INPUT_VAR3_X;
    Internal_INPUT_VAR3.Y := INPUT_VAR3_Y;
    
END_FUNCTION_BLOCK