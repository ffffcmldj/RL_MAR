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
    exe_prev : BOOL;
    sortValid : BOOL;
END_VAR

(* Rising edge detection for single execution *)
IF exe AND NOT exe_prev THEN
    (* Initialize outputs to failure state *)
    error := TRUE;
    status := 16#8A01;
    sortValid := TRUE;
    
    (* Copy input array to local working array *)
    FOR i := 1 TO n DO
        seq_local[i] := seq[i];
    END_FOR;
    
    (* Selection sort algorithm *)
    FOR i := 1 TO n-1 DO
        min_idx := i;
        FOR j := i+1 TO n DO
            IF seq_local[j] < seq_local[min_idx] THEN
                min_idx := j;
            END_IF;
        END_FOR;
        
        IF min_idx <> i THEN
            temp := seq_local[i];
            seq_local[i] := seq_local[min_idx];
            seq_local[min_idx] := temp;
        END_IF;
    END_FOR;
    
    (* Verify array is sorted in ascending order *)
    FOR i := 1 TO n-1 DO
        IF seq_local[i] > seq_local[i+1] THEN
            sortValid := FALSE;
            EXIT;
        END_IF;
    END_FOR;
    
    (* If verification passed, write back results and set success status *)
    IF sortValid THEN
        FOR i := 1 TO n DO
            seq[i] := seq_local[i];
        END_FOR;
        
        error := FALSE;
        status := 16#0000;
    END_IF;
END_IF;

(* Update edge detection variable *)
exe_prev := exe;

END_FUNCTION_BLOCK