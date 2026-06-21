FUNCTION_BLOCK SelectSort
VAR_INPUT
    exe : BOOL;
    seq : ARRAY[1..100] OF INT;
END_VAR

VAR_OUTPUT
    error : BOOL;
    status : WORD;
END_VAR

VAR
    i : INT;
    j : INT;
    min_idx : INT;
    temp : INT;
    n : INT;
    sort_successful : BOOL;
END_VAR

IF exe THEN
    error := FALSE;
    status := 16#0000;
    sort_successful := TRUE;
    
    n := 100;
    
    FOR i := 1 TO n-1 DO
        min_idx := i;
        
        FOR j := i+1 TO n DO
            IF seq[j] < seq[min_idx] THEN
                min_idx := j;
            END_IF;
        END_FOR;
        
        IF min_idx <> i THEN
            temp := seq[i];
            seq[i] := seq[min_idx];
            seq[min_idx] := temp;
        END_IF;
    END_FOR;
    
    IF NOT sort_successful THEN
        error := TRUE;
        status := 16#8A01;
    END_IF;
    
ELSE
    error := FALSE;
    status := 16#0000;
END_IF;

END_FUNCTION_BLOCK;