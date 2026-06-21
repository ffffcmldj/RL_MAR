FUNCTION_BLOCK hf_9
VAR_INPUT
    sortDirection : BOOL;  (* FALSE: ascending, TRUE: descending *)
    arr : ARRAY[1..1000] OF DINT;
END_VAR

VAR_OUTPUT
    error : BOOL;
    status : WORD;
    sorted_arr : ARRAY[1..1000] OF DINT;
END_VAR

VAR
    i, j, gap : DINT;
    temp : DINT;
    N : DINT := 1000;  (* Fixed array size *)
END_VAR

(* 1. Copy arr to sorted_arr *)
FOR i := 1 TO N DO
    sorted_arr[i] := arr[i];
END_FOR;

(* 2. Input validation *)
IF N <= 1 THEN
    error := TRUE;
    status := 16#8200;
    RETURN;
ELSIF N > 1000 THEN
    error := TRUE;
    status := 16#8201;
    RETURN;
END_IF;

(* 3. Shell Sort implementation *)
gap := N / 2;
WHILE gap > 0 DO
    (* Perform insertion sort for elements spaced by gap *)
    FOR i := gap + 1 TO N DO
        temp := sorted_arr[i];
        j := i;
        
        (* Inner loop for shifting elements *)
        WHILE j > gap DO
            (* Comparison based on sortDirection *)
            IF sortDirection THEN  (* Descending order *)
                IF temp > sorted_arr[j - gap] THEN
                    sorted_arr[j] := sorted_arr[j - gap];
                    j := j - gap;
                ELSE
                    EXIT;
                END_IF;
            ELSE  (* Ascending order *)
                IF temp < sorted_arr[j - gap] THEN
                    sorted_arr[j] := sorted_arr[j - gap];
                    j := j - gap;
                ELSE
                    EXIT;
                END_IF;
            END_IF;
        END_WHILE;
        
        sorted_arr[j] := temp;
    END_FOR;
    
    gap := gap / 2;
END_WHILE;

(* 4. Set success status *)
error := FALSE;
status := 16#0000;

END_FUNCTION_BLOCK