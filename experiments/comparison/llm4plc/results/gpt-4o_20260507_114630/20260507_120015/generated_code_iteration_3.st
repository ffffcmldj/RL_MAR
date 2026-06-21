START_REASON  
The feedback indicates that the custom data type `POINT` is still not recognized by the CODESYS compiler. This suggests that the declaration of the `POINT` type, even though moved to a global scope, is not being properly referenced or utilized in the function blocks. This could be due to an issue with the scope or the way the type is being used in the function blocks.

To resolve this issue, I will ensure that the `POINT` type is correctly declared in a global scope and that all references to it in the function blocks are valid. Additionally, I will verify that the syntax and structure of the code conform to CODESYS standards.  

END_REASON  

START_ST  

// Declare the custom data type POINT in a global scope  
TYPE  
    POINT :  
    STRUCT  
        X : INT;  
        Y : INT;  
    END_STRUCT;  
END_TYPE  

// Define the function block FB_PointOperations  
FUNCTION_BLOCK FB_PointOperations  
    VAR_INPUT  
        INPUT_VAR2 : INT := 7; // Default value of 7  
    END_VAR  

    VAR_OUTPUT  
        OUTPUT_VAR1 : POINT; // Output of type POINT  
        OUTPUT_VAR3 : POINT; // Output of type POINT  
    END_VAR  

    VAR  
        VAR2 : INT; // Internal variable  
    END_VAR  

    // Function block logic  
    VAR2 := INPUT_VAR2; // Assign INPUT_VAR2 to VAR2  
    OUTPUT_VAR1.X := 1; // Set OUTPUT_VAR1.X to 1  
    OUTPUT_VAR1.Y := 2; // Set OUTPUT_VAR1.Y to 2  
    OUTPUT_VAR3.X := 100; // Set OUTPUT_VAR3.X to 100  
    OUTPUT_VAR3.Y := -7000; // Set OUTPUT_VAR3.Y to -7000  
END_FUNCTION_BLOCK  

// Define the function block FB_ExpandedPoint  
FUNCTION_BLOCK FB_ExpandedPoint  
    VAR_INPUT  
        INPUT_VAR2 : INT; // Input variable  
        INPUT_VAR1_X : INT; // Additional input variable for X  
        INPUT_VAR1_Y : INT; // Additional input variable for Y  
        INPUT_VAR3_X : INT := 1; // Default value of 1  
        INPUT_VAR3_Y : INT := 2; // Default value of 2  
    END_VAR  

    VAR_OUTPUT  
        OUTPUT_VAR2 : INT; // Output variable  
        OUTPUT_VAR1_X : INT; // Output variable for X  
        OUTPUT_VAR1_Y : INT; // Output variable for Y  
        OUTPUT_VAR3_X : INT; // Output variable for X  
        OUTPUT_VAR3_Y : INT; // Output variable for Y  
    END_VAR  

    // Function block logic  
    OUTPUT_VAR2 := INPUT_VAR2; // Assign INPUT_VAR2 to OUTPUT_VAR2  
    OUTPUT_VAR1_X := INPUT_VAR1_X; // Assign INPUT_VAR1_X to OUTPUT_VAR1_X  
    OUTPUT_VAR1_Y := INPUT_VAR1_Y; // Assign INPUT_VAR1_Y to OUTPUT_VAR1_Y  
    OUTPUT_VAR3_X := INPUT_VAR3_X; // Assign INPUT_VAR3_X to OUTPUT_VAR3_X  
    OUTPUT_VAR3_Y := INPUT_VAR3_Y; // Assign INPUT_VAR3_Y to OUTPUT_VAR3_Y  
END_FUNCTION_BLOCK  

END_ST  