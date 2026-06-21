TYPE
    SortStatus : WORD := 16#0000;
    SortErrorCode : WORD := 16#8A01;
END_TYPE

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
    sort_successful : BOOL;
END_VAR

(* Initialize outputs to error state *)
error := TRUE;
status := SortErrorCode;

(* Execute sorting on rising edge of exe *)
IF exe AND NOT exe_prev THEN
    (* Copy input array to local working array *)
    seq_local := seq;
    sort_successful := TRUE;
    
    (* Selection sort algorithm *)
    FOR i := 1 TO n-1 DO
        min_idx := i;
        FOR j := i+1 TO n DO
            IF seq_local[j] < seq_local[min_idx] THEN
                min_idx := j;
            END_IF;
        END_FOR;
        
        (* Swap elements if necessary *)
        IF min_idx <> i THEN
            temp := seq_local[i];
            seq_local[i] := seq_local[min_idx];
            seq_local[min_idx] := temp;
        END_IF;
    END_FOR;
    
    (* Verify sorting was successful *)
    sort_successful := TRUE;
    FOR i := 1 TO n-1 DO
        IF seq_local[i] > seq_local[i+1] THEN
            sort_successful := FALSE;
            EXIT;
        END_IF;
    END_FOR;
    
    (* Update outputs based on verification *)
    IF sort_successful THEN
        (* Copy sorted array back to output *)
        seq := seq_local;
        error := FALSE;
        status := SortStatus;
    ELSE
        (* Sorting verification failed *)
        error := TRUE;
        status := SortErrorCode;
    END_IF;
END_IF;

(* Store previous execution state *)
exe_prev := exe;

END_FUNCTION_BLOCK