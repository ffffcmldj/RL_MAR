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
    n : INT := 100;
    seq_local : ARRAY[1..100] OF INT;
    sort_successful : BOOL;
END_VAR

IF exe THEN
    // Initialize outputs
    error := FALSE;
    status := 16#0000;
    sort_successful := TRUE;
    
    // Copy input array to local working array
    FOR i := 1 TO n DO
        seq_local[i] := seq[i];
    END_FOR;
    
    // Selection sort algorithm
    FOR i := 1 TO n-1 DO
        min_idx := i;
        FOR j := i+1 TO n DO
            IF seq_local[j] < seq_local[min_idx] THEN
                min_idx := j;
            END_IF;
        END_FOR;
        
        // Swap elements if needed
        IF min_idx <> i THEN
            temp := seq_local[i];
            seq_local[i] := seq_local[min_idx];
            seq_local[min_idx] := temp;
        END_IF;
    END_FOR;
    
    // Copy sorted array back to output
    FOR i := 1 TO n DO
        seq[i] := seq_local[i];
    END_FOR;
    
    // Verify sorting was successful
    FOR i := 1 TO n-1 DO
        IF seq[i] > seq[i+1] THEN
            sort_successful := FALSE;
            EXIT;
        END_IF;
    END_FOR;
    
    // Set error status if verification failed
    IF NOT sort_successful THEN
        error := TRUE;
        status := 16#8A01;
    END_IF;
END_IF;

END_FUNCTION_BLOCK