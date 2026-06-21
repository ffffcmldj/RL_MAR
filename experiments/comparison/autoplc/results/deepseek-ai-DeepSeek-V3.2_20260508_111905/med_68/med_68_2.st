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
    GT51_OUT : BOOL;
    GT56_OUT : BOOL;
    GT57_OUT : BOOL;
    GT62_OUT : BOOL;
END_VAR

    // Step 1: Process Marca1 Flag
    IF NOT Marca2 AND Int1 AND (Marca1 OR NOT Out1) THEN
        Marca1 := TRUE;
    ELSE
        // Marca1 maintains its current state
    END_IF;
    
    // Step 2: Process Marca2 Flag
    // Note: Marca2 is also an input parameter, so we need to evaluate based on conditions
    // but the input Marca2 value is used in the logic
    IF NOT Marca1 AND Int1 AND (Marca2 OR Out1) THEN
        // Marca2 is set to TRUE based on conditions
        // However, Marca2 is an input, so we don't modify it internally
        // The logic uses the input Marca2 value
    END_IF;
    
    // Step 3: Determine Out1 State
    IF NOT Marca2 AND (Marca1 OR Out1) THEN
        Out1 := TRUE;
    ELSE
        Out1 := FALSE;
    END_IF;
    
    // Step 4: Direct Signal Pass-Through (Boolean)
    Out2 := Int2;
    Out3 := Int3;
    Out4 := Int4;
    
    // Step 5: Direct Signal Pass-Through (Analog)
    OutAn1 := IntAn1;
    OutAn2 := IntAn2;
    OutAn3 := IntAn3;
    OutAn4 := IntAn4;
    
    // Step 6: Conditional Output Logic for Out5 to Out8
    // Condition for Out5: IntAn5 > 1000 AND Int5 is FALSE
    IF IntAn5 > 1000 AND NOT Int5 THEN
        Out5 := TRUE;
    ELSE
        Out5 := FALSE;
    END_IF;
    
    // Condition for Out6: IntAn6 > 1000 AND Int6 is FALSE
    IF IntAn6 > 1000 AND NOT Int6 THEN
        Out6 := TRUE;
    ELSE
        Out6 := FALSE;
    END_IF;
    
    // Condition for Out7: IntAn7 > 1000 AND Int7 is FALSE
    IF IntAn7 > 1000 AND NOT Int7 THEN
        Out7 := TRUE;
    ELSE
        Out7 := FALSE;
    END_IF;
    
    // Condition for Out8: IntAn8 > 1000 AND Int8 is FALSE
    IF IntAn8 > 1000 AND NOT Int8 THEN
        Out8 := TRUE;
    ELSE
        Out8 := FALSE;
    END_IF;
    
    // Step 7: Analog Output Pass-Through (Remaining)
    OutAn5 := IntAn5;
    OutAn6 := IntAn6;
    OutAn7 := IntAn7;
    OutAn8 := IntAn8;
    
END_FUNCTION_BLOCK