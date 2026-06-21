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
END_VAR

// Main logic execution
// Logic for Marca1 flag
IF NOT Marca2 AND (Marca1 OR NOT Out1) AND Int1 THEN
    Marca1 := TRUE;
ELSE
    Marca1 := FALSE;
END_IF;

// Logic for Marca2 flag (note: Marca2 is both input and internal state)
IF NOT Marca1 AND (Marca2 OR Out1) AND Int1 THEN
    Marca2 := TRUE;
ELSE
    Marca2 := FALSE;
END_IF;

// Latch behavior for Out1
IF NOT Marca2 AND (Marca1 OR Out1) THEN
    Out1 := TRUE;
ELSE
    Out1 := FALSE;
END_IF;

// Boolean pass-through for Out2, Out3, Out4
Out2 := Int2;
Out3 := Int3;
Out4 := Int4;

// Unsigned integer pass-through for OutAn1 to OutAn4
OutAn1 := IntAn1;
OutAn2 := IntAn2;
OutAn3 := IntAn3;
OutAn4 := IntAn4;

// Conditional output logic for Out5 to Out8
// Out5 condition: IntAn5 > 1000 AND NOT Int5
Out5 := (IntAn5 > 1000) AND NOT Int5;

// Out6 condition: IntAn6 > 1000 AND NOT Int6
Out6 := (IntAn6 > 1000) AND NOT Int6;

// Out7 condition: IntAn7 > 1000 AND NOT Int7
Out7 := (IntAn7 > 1000) AND NOT Int7;

// Out8 condition: IntAn8 > 1000 AND NOT Int8
Out8 := (IntAn8 > 1000) AND NOT Int8;

// Pass-through for analog outputs OutAn5 to OutAn8
OutAn5 := IntAn5;
OutAn6 := IntAn6;
OutAn7 := IntAn7;
OutAn8 := IntAn8;

END_FUNCTION_BLOCK