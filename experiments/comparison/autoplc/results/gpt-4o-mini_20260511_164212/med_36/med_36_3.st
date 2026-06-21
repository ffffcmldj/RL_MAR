FUNCTION_BLOCK FB_ExpandedPoint
    VAR_INPUT
        INPUT_VAR2 : INT := 7; // Default value
    END_VAR_INPUT

    VAR_OUTPUT
        OUTPUT_VAR1 : POINT;
        OUTPUT_VAR3 : POINT;
    END_VAR_OUTPUT

    VAR
        VAR2 : INT; // Internal variable
    END_VAR

    // Assign the value of INPUT_VAR2 to VAR2
    VAR2 := INPUT_VAR2;

    // Set OUTPUT_VAR1 values
    OUTPUT_VAR1.X := 1;
    OUTPUT_VAR1.Y := 2;

    // Set OUTPUT_VAR3 values
    OUTPUT_VAR3.X := 100;
    OUTPUT_VAR3.Y := -7000;

END_FUNCTION_BLOCK

TYPE POINT :
STRUCT
    X : INT;
    Y : INT;
END_STRUCT
END_TYPE