FUNCTION_BLOCK FB_Sum
VAR_INPUT
    maxValue : INT;
END_VAR
VAR_OUTPUT
    wData : WORD;
END_VAR

VAR
    II : INT;
END_VAR

BEGIN
    wData := 0;
    
    FOR II := 0 TO maxValue DO
        wData := wData + WORD(II);
    END_FOR;
END_FUNCTION_BLOCK