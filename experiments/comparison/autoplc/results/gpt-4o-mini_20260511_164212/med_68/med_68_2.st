FUNCTION_BLOCK FB_SignalControl
    VAR_INPUT
        Int1 : BOOL;
        Int2 : BOOL;
        Int3 : BOOL;
        Int4 : BOOL;
        Int5 : BOOL;
        Int6 : BOOL;
        Int7 : BOOL;
        Int8 : BOOL;
        IntAn1 : UINT;
        IntAn2 : UINT;
        IntAn3 : UINT;
        IntAn4 : UINT;
        IntAn5 : UINT;
        IntAn6 : UINT;
        IntAn7 : UINT;
        IntAn8 : UINT;
        Marca2 : BOOL;
    END_VAR

    VAR_OUTPUT
        Out1 : BOOL;
        Out2 : BOOL;
        Out3 : BOOL;
        Out4 : BOOL;
        Out5 : BOOL;
        Out6 : BOOL;
        Out7 : BOOL;
        Out8 : BOOL;
        OutAn1 : UINT;
        OutAn2 : UINT;
        OutAn3 : UINT;
        OutAn4 : UINT;
        OutAn5 : UINT;
        OutAn6 : UINT;
        OutAn7 : UINT;
        OutAn8 : UINT;
    END_VAR

    VAR
        Marca1 : BOOL := FALSE;
        i : INT; // Loop variable for processing outputs
    END_VAR

    // Direct Signal Pass-Through
    Out2 := Int2;
    Out3 := Int3;
    Out4 := Int4;
    OutAn1 := IntAn1;
    OutAn2 := IntAn2;
    OutAn3 := IntAn3;
    OutAn4 := IntAn4;

    // Latch Logic for Out1
    IF (Marca2 = FALSE) THEN
        IF (Marca1 OR NOT Out1) AND Int1 THEN
            Marca1 := TRUE;
        END_IF;
    END_IF;

    IF (Marca1 = FALSE) THEN
        IF (Marca2 OR Out1) AND Int1 THEN
            Marca2 := TRUE;
        END_IF;
    END_IF;

    // Update Out1 based on Marca1 and Marca2
    IF (Marca2 = FALSE) THEN
        IF (Marca1 OR Out1) THEN
            Out1 := TRUE;
        END_IF;
    END_IF;

    // Conditional Outputs Logic
    Out5 := (IntAn5 > 1000) AND (NOT Int5);
    Out6 := (IntAn6 > 1000) AND (NOT Int6);
    Out7 := (IntAn7 > 1000) AND (NOT Int7);
    Out8 := (IntAn8 > 1000) AND (NOT Int8);
END_FUNCTION_BLOCK