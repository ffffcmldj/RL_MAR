START_REASON
The validation feedback indicates that the CODESYS compiler does not recognize the type 'POINT'. This is likely because the TYPE definition for POINT is placed outside the FUNCTION_BLOCK, but in CODESYS, type definitions might need to be declared within the appropriate scope or in a separate DUT (Data Unit Type) section. In structured text for CODESYS, user-defined types like POINT are typically defined in a separate type declaration area (e.g., in a DUT), not directly within the FUNCTION_BLOCK code. However, since the task requires generating a complete ST code block, I should define the POINT type inside the FUNCTION_BLOCK or ensure it is properly scoped. Based on common CODESYS practices, I can define the POINT structure as a local type within the FUNCTION_BLOCK using TYPE...END_TYPE inside the VAR section or as a global definition, but for simplicity and to avoid scope issues, I will move the POINT definition to a DUT-like section at the top of the code, before the FUNCTION_BLOCK. This should make it accessible. I will restructure the code to include the type definition in a way that CODESYS accepts, typically by placing it in a TYPE block before the FUNCTION_BLOCK. I will also ensure all variable declarations use END_VAR correctly and maintain ASCII-only characters to prevent encoding errors.
END_REASON

START_ST
TYPE POINT :
STRUCT
    X : INT;
    Y : INT;
END_STRUCT
END_TYPE

FUNCTION_BLOCK FB_PointOperations
VAR_INPUT
    INPUT_VAR2 : INT := 7;
END_VAR
VAR_OUTPUT
    OUTPUT_VAR1 : POINT;
    OUTPUT_VAR3 : POINT;
END_VAR
VAR
    VAR2 : INT;
END_VAR

    VAR2 := INPUT_VAR2;
    OUTPUT_VAR1.X := 1;
    OUTPUT_VAR1.Y := 2;
    OUTPUT_VAR3.X := 100;
    OUTPUT_VAR3.Y := -7000;

END_FUNCTION_BLOCK
END_ST