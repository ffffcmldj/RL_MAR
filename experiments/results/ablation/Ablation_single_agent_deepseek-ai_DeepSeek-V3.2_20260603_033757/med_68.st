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
    Marca1 : BOOL;
END_VAR

// Logic Implementation
// Marca1 and Marca2 latch logic
Marca1 := (NOT Marca2 AND (Marca1 OR NOT Out1) AND Int1) OR (Marca1 AND NOT Int1);
Marca2 := (NOT Marca1 AND (Marca2 OR Out1) AND Int1) OR (Marca2 AND NOT Int1);

// Out1 latch behavior
Out1 := (NOT Marca2 AND (Marca1 OR Out1)) OR (Out1 AND Marca2);

// Direct Boolean pass-through
Out2 := Int2;
Out3 := Int3;
Out4 := Int4;

// Direct unsigned integer pass-through
OutAn1 := IntAn1;
OutAn2 := IntAn2;
OutAn3 := IntAn3;
OutAn4 := IntAn4;

// Conditional output logic for Out5 to Out8
Out5 := (IntAn5 > 1000) AND NOT Int5;
Out6 := (IntAn6 > 1000) AND NOT Int6;
Out7 := (IntAn7 > 1000) AND NOT Int7;
Out8 := (IntAn8 > 1000) AND NOT Int8;

// Analog outputs pass-through for IntAn5 to IntAn8
OutAn5 := IntAn5;
OutAn6 := IntAn6;
OutAn7 := IntAn7;
OutAn8 := IntAn8;

END_FUNCTION_BLOCK