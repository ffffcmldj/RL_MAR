// Move the type declaration to the 'Data Types' section of the Codesys project
// This section is separate from the function block code and ensures global accessibility
// Example:
TYPE
    POINT :
    STRUCT
        X : INT;
        Y : INT;
    END_STRUCT;
END_TYPE
// Save this in the 'Data Types' section or a library file

FUNCTION_BLOCK FB_PointOperations
    VAR_INPUT
        INPUT_VAR2 : INT := 7; // Default value of 7
    END_VAR

    VAR_OUTPUT
        OUTPUT_VAR1 : POINT;
        OUTPUT_VAR3 : POINT;
    END_VAR

    VAR
        VAR2 : INT;
    END_VAR

    // Function block code
    VAR2 := INPUT_VAR2; // Assign the value of INPUT_VAR2 to VAR2

    // Set OUTPUT_VAR1.X to 1 and OUTPUT_VAR1.Y to 2
    OUTPUT_VAR1.X := 1;
    OUTPUT_VAR1.Y := 2;

    // Set OUTPUT_VAR3.X to 100 and OUTPUT_VAR3.Y to -7000
    OUTPUT_VAR3.X := 100;
    OUTPUT_VAR3.Y := -7000;
END_FUNCTION_BLOCK