ructured-text
START_ST
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
END_VAR_INPUT

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
END_VAR_OUTPUT

VAR
    Marca1 : BOOL;
    state : INT; // THE STATE VARIABLE
END_VAR

// STATE 0: INITIALIZE
IF state = 0 THEN
    Out1 := FALSE;
    Out2 := FALSE;
    Out3 := FALSE;
    Out4 := FALSE;
    Out5 := FALSE;
    Out6 := FALSE;
    Out7 := FALSE;
    Out8 := FALSE;

    // Transition to STATE 1
    IF Int1 THEN
        state := 1;
    END_IF

// STATE 1: LATCHING OUT1
ELSIF state = 1 THEN
    // Latch behavior for Out1
    IF NOT Marca2 THEN
        IF Marca1 OR NOT Out1 THEN
            Marca1 := TRUE;
        END_IF
    END_IF

    IF NOT Marca1 THEN
        IF Marca2 OR Out1 THEN
            Marca2 := TRUE;
        END_IF
    END_IF

    Out1 := Marca1 OR Out1;

    // Transition to STATE 0
    IF Marca2 OR NOT Int1 THEN
        state := 0;
    END_IF

    // Transition to STATE 2
    IF Out1 AND NOT Marca2 THEN
        state := 2;
    END_IF

// STATE 2: DIRECT SIGNAL PASS-THROUGH
ELSIF state = 2 THEN
    Out2 := Int2;
    Out3 := Int3;
    Out4 := Int4;

    // Transition to STATE 3
    IF Out2 AND Out3 AND Out4 THEN
        state := 3;
    END_IF

// STATE 3: CONDITIONAL OUTPUT LOGIC
ELSIF state = 3 THEN
    Out5 := (IntAn5 > 1000) AND NOT Int5;
    Out6 := (IntAn6 > 1000) AND NOT Int6;
    Out7 := (IntAn7 > 1000) AND NOT Int7;
    Out8 := (IntAn8 > 1000) AND NOT Int8;

    // Transition to STATE 2 if conditions for Out5 to Out8 are not met
    IF NOT (Out5 OR Out6 OR Out7 OR Out8) THEN
        state := 2;
    END_IF
END_IF

// Pass-through for unsigned integers
OutAn1 := IntAn1;
OutAn2 := IntAn2;
OutAn3 := IntAn3;
OutAn4 := IntAn4;
OutAn5 := IntAn5;
OutAn6 := IntAn6;
OutAn7 := IntAn7;
OutAn8 := IntAn8;

END_FUNCTION_BLOCK
END_ST