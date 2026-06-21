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

METHOD Main : BOOL
VAR_INPUT
    Execute : BOOL;
END_VAR
VAR_OUTPUT
    Done : BOOL;
END_VAR

    IF Execute THEN
        OUTPUT_VAR1 := INPUT_VAR1;
        COUNTER := INPUT_COUNTER;
        
        REPEAT
            OUTPUT_VAR1 := OUTPUT_VAR1 * 2;
            COUNTER := COUNTER - 1;
        UNTIL COUNTER <= 0
        END_REPEAT;
        
        Done := TRUE;
    ELSE
        Done := FALSE;
    END_IF;
    
    Main := Done;
END_METHOD

END_FUNCTION_BLOCK