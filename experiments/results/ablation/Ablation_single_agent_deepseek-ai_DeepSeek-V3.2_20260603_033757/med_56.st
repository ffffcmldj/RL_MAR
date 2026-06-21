FUNCTION_BLOCK FB_SimpleRepeat
VAR_INPUT
    INPUT_VAR1 : INT := 2;
    INPUT_COUNTER : INT := 4;
END_VAR

VAR_OUTPUT
    OUTPUT_VAR1 : INT;
END_VAR

VAR
    COUNTER : INT;
END_VAR

METHOD Run : BOOL
VAR_INPUT
    bExecute : BOOL;
END_VAR

VAR
    nTempCounter : INT;
END_VAR

IF bExecute THEN
    OUTPUT_VAR1 := INPUT_VAR1;
    nTempCounter := INPUT_COUNTER;
    
    REPEAT
        OUTPUT_VAR1 := OUTPUT_VAR1 * 2;
        nTempCounter := nTempCounter - 1;
    UNTIL nTempCounter <= 0
    END_REPEAT;
    
    Run := TRUE;
ELSE
    Run := FALSE;
END_IF;

END_METHOD

END_FUNCTION_BLOCK