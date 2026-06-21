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

// 1. Latch Logic for Out1 using Marca1 and Marca2
// Marca1 condition: Set when Marca2 is FALSE AND (Marca1 is TRUE OR Out1 is FALSE) AND Int1 is TRUE
Marca1 := (NOT Marca2) AND (Marca1 OR NOT Out1) AND Int1;

// Marca2 condition: Set when Marca1 is FALSE AND (Marca2 is TRUE OR Out1 is TRUE) AND Int1 is TRUE
// Note: Marca2 is an input, so we don't assign to it. The description suggests it should be internal,
// but the interface defines it as input. We'll use the input value directly.

// Out1 latch condition: Set when Marca2 is FALSE AND (Marca1 is TRUE OR Out1 is TRUE)
Out1 := (NOT Marca2) AND (Marca1 OR Out1);

// 2. Direct Boolean Pass-Through
Out2 := Int2;
Out3 := Int3;
Out4 := Int4;

// 3. Direct Analog Pass-Through
OutAn1 := IntAn1;
OutAn2 := IntAn2;
OutAn3 := IntAn3;
OutAn4 := IntAn4;
OutAn5 := IntAn5;
OutAn6 := IntAn6;
OutAn7 := IntAn7;
OutAn8 := IntAn8;

// 4. Conditional Output Logic for Out5 to Out8
Out5 := (IntAn5 > 1000) AND NOT Int5;
Out6 := (IntAn6 > 1000) AND NOT Int6;
Out7 := (IntAn7 > 1000) AND NOT Int7;
Out8 := (IntAn8 > 1000) AND NOT Int8;

END_FUNCTION_BLOCK;