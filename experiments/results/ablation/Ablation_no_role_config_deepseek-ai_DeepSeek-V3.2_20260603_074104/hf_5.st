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
    seq_local : ARRAY[1..100] OF INT;
    exe_prev : BOOL;
    sort_successful : BOOL;
END_VAR

(* Initialize outputs *)
error := TRUE;
status := 16#8A01;

(* Rising edge detection for execution trigger *)
IF exe AND NOT exe_prev THEN
    (* Copy input array to local working array *)
    FOR i := 1 TO 100 DO
        seq_local[i] := seq[i];
    END_FOR;
    
    (* Selection sort algorithm *)
    FOR i := 1 TO 99 DO
        min_idx := i;
        FOR j := i+1 TO 100 DO
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
    
    (* Verify sorting result *)
    sort_successful := TRUE;
    FOR i := 1 TO 99 DO
        IF seq_local[i] > seq_local[i+1] THEN
            sort_successful := FALSE;
            EXIT;
        END_IF;
    END_FOR;
    
    (* Set outputs based on verification *)
    IF sort_successful THEN
        (* Copy sorted array back to output *)
        FOR i := 1 TO 100 DO
            seq[i] := seq_local[i];
        END_FOR;
        error := FALSE;
        status := 16#0000;
    ELSE
        error := TRUE;
        status := 16#8A01;
    END_IF;
END_IF;

(* Store previous execution state *)
exe_prev := exe;
END_FUNCTION_BLOCK