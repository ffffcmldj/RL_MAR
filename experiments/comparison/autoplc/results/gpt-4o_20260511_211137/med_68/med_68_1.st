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
    END_VAR

    // Logic for Marca1
    IF NOT Marca2 THEN
        IF Int1 OR (Marca1 OR NOT Out1) THEN
            Marca1 := TRUE;
        END_IF
    END_IF

    // Logic for Marca2
    IF NOT Marca1 THEN
        IF Int1 OR (Marca2 OR Out1) THEN
            Marca2 := TRUE;
        END_IF
    END_IF

    // Latch Behavior for Out1
    IF NOT Marca2 AND (Marca1 OR Out1) THEN
        Out1 := TRUE;
    ELSE
        Out1 := FALSE;
    END_IF

    // Direct Signal Pass-Through
    Out2 := Int2;
    Out3 := Int3;
    Out4 := Int4;

    OutAn1 := IntAn1;
    OutAn2 := IntAn2;
    OutAn3 := IntAn3;
    OutAn4 := IntAn4;

    // Conditional Output Logic
    IF IntAn5 > 1000 AND NOT Int5 THEN
        Out5 := TRUE;
    ELSE
        Out5 := FALSE;
    END_IF

    IF IntAn6 > 1000 AND NOT Int6 THEN
        Out6 := TRUE;
    ELSE
        Out6 := FALSE;
    END_IF

    IF IntAn7 > 1000 AND NOT Int7 THEN
        Out7 := TRUE;
    ELSE
        Out7 := FALSE;
    END_IF

    IF IntAn8 > 1000 AND NOT Int8 THEN
        Out8 := TRUE;
    ELSE
        Out8 := FALSE;
    END_IF

    // Pass-through for analog outputs
    OutAn5 := IntAn5;
    OutAn6 := IntAn6;
    OutAn7 := IntAn7;
    OutAn8 := IntAn8;
END_FUNCTION_BLOCK