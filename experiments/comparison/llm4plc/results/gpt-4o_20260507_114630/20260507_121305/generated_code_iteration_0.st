plaintext
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
    state : INT := 0;
END_VAR

// Main logic
CASE state OF
    // STATE 0: INITIALIZE
    0:
        // Initialize all outputs to default states
        Out1 := FALSE;
        Out2 := FALSE;
        Out3 := FALSE;
        Out4 := FALSE;
        Out5 := FALSE;
        Out6 := FALSE;
        Out7 := FALSE;
        Out8 := FALSE;
        OutAn1 := 0;
        OutAn2 := 0;
        OutAn3 := 0;
        OutAn4 := 0;
        OutAn5 := 0;
        OutAn6 := 0;
        OutAn7 := 0;
        OutAn8 := 0;

        // Initialize internal variables
        Marca1 := FALSE;

        // Transition to STATE 1
        state := 1;

    // STATE 1: LATCH CONTROL FOR OUT1
    1:
        // Logic for Marca1
        IF NOT Marca2 AND (Marca1 OR NOT Out1 OR Int1) THEN
            Marca1 := TRUE;
        ELSE
            Marca1 := FALSE;
        END_IF;

        // Logic for Marca2
        IF NOT Marca1 AND (Marca2 OR Out1 OR Int1) THEN
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

        // Transition to STATE 2
        state := 2;

    // STATE 2: DIRECT PASS-THROUGH
    2:
        // Boolean pass-through
        Out2 := Int2;
        Out3 := Int3;
        Out4 := Int4;

        // Unsigned integer pass-through
        OutAn1 := IntAn1;
        OutAn2 := IntAn2;
        OutAn3 := IntAn3;
        OutAn4 := IntAn4;

        // Transition to STATE 3
        state := 3;

    // STATE 3: CONDITIONAL OUTPUTS
    3:
        // Conditional logic for Out5
        IF (IntAn5 > 1000) AND NOT Int5 THEN
            Out5 := TRUE;
        ELSE
            Out5 := FALSE;
        END_IF;

        // Conditional logic for Out6
        IF (IntAn6 > 1000) AND NOT Int6 THEN
            Out6 := TRUE;
        ELSE
            Out6 := FALSE;
        END_IF;

        // Conditional logic for Out7
        IF (IntAn7 > 1000) AND NOT Int7 THEN
            Out7 := TRUE;
        ELSE
            Out7 := FALSE;
        END_IF;

        // Conditional logic for Out8
        IF (IntAn8 > 1000) AND NOT Int8 THEN
            Out8 := TRUE;
        ELSE
            Out8 := FALSE;
        END_IF;

        // Transition back to STATE 1 for the next scan cycle
        state := 1;

END_CASE;
END_FUNCTION_BLOCK
END_ST