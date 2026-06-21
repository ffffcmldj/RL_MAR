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

    // Main execution logic
    OUTPUT_VAR2 := INPUT_VAR2;
    OUTPUT_VAR1_X := 1;
    OUTPUT_VAR1_Y := 2;
    OUTPUT_VAR3_X := 100;
    OUTPUT_VAR3_Y := -7000;
END_FUNCTION_BLOCK