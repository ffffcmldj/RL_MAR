FUNCTION_BLOCK SignalControl
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
    Marca1 : BOOL;
    GT51_OUT : BOOL;
    GT56_OUT : BOOL;
    GT57_OUT : BOOL;
    GT62_OUT : BOOL;
END_VAR

    (* Logic for Marca1 flag *)
    IF NOT Marca2 AND ((Marca1 OR NOT Out1) AND Int1) THEN
        Marca1 := TRUE;
    ELSE
        Marca1 := FALSE;
    END_IF;

    (* Latch behavior for Out1 *)
    IF NOT Marca2 AND (Marca1 OR Out1) THEN
        Out1 := TRUE;
    ELSE
        Out1 := FALSE;
    END_IF;

    (* Direct Boolean pass-through *)
    Out2 := Int2;
    Out3 := Int3;
    Out4 := Int4;

    (* Direct unsigned integer pass-through *)
    OutAn1 := IntAn1;
    OutAn2 := IntAn2;
    OutAn3 := IntAn3;
    OutAn4 := IntAn4;

    (* Conditional outputs with comparison results *)
    GT51_OUT := (IntAn5 > 1000);
    GT56_OUT := (IntAn6 > 1000);
    GT57_OUT := (IntAn7 > 1000);
    GT62_OUT := (IntAn8 > 1000);

    (* Conditional output logic for Out5 *)
    IF GT51_OUT AND NOT Int5 THEN
        Out5 := TRUE;
    ELSE
        Out5 := FALSE;
    END_IF;

    (* Conditional output logic for Out6 *)
    IF GT56_OUT AND NOT Int6 THEN
        Out6 := TRUE;
    ELSE
        Out6 := FALSE;
    END_IF;

    (* Conditional output logic for Out7 *)
    IF GT57_OUT AND NOT Int7 THEN
        Out7 := TRUE;
    ELSE
        Out7 := FALSE;
    END_IF;

    (* Conditional output logic for Out8 *)
    IF GT62_OUT AND NOT Int8 THEN
        Out8 := TRUE;
    ELSE
        Out8 := FALSE;
    END_IF;

    (* Pass through remaining analog values *)
    OutAn5 := IntAn5;
    OutAn6 := IntAn6;
    OutAn7 := IntAn7;
    OutAn8 := IntAn8;

END_FUNCTION_BLOCK;