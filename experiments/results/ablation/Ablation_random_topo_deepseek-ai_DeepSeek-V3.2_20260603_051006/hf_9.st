FUNCTION_BLOCK ShellSortFB
VAR_INPUT
    sortDirection : BOOL; (* FALSE = Ascending, TRUE = Descending *)
    arr : ARRAY[1..1000] OF DINT;
END_VAR
VAR_OUTPUT
    error : BOOL;
    status : WORD;
    sorted_arr : ARRAY[1..1000] OF DINT;
END_VAR
VAR
    i : DINT;
    j : DINT;
    gap : DINT;
    temp : DINT;
    N : DINT := 1000;
    ascending : BOOL;
END_VAR

(* Step 1: Copy input array to output array *)
sorted_arr := arr;

(* Step 2: Initialize error outputs *)
error := FALSE;
status := 16#0000;

(* Step 3: Array size validation *)
IF N <= 1 THEN
    error := TRUE;
    status := 16#8200;
    RETURN;
END_IF;

IF N > 1000 THEN
    error := TRUE;
    status := 16#8201;
    RETURN;
END_IF;

(* Step 4: Determine sorting direction *)
ascending := NOT sortDirection; (* TRUE for ascending, FALSE for descending *)

(* Step 5: Shell Sort Algorithm *)
gap := N / 2;

WHILE gap > 0 DO
    i := gap + 1;
    
    WHILE i <= N DO
        temp := sorted_arr[i];
        j := i;
        
        WHILE (j > gap) AND (
            (ascending AND (sorted_arr[j - gap] > temp)) OR
            (NOT ascending AND (sorted_arr[j - gap] < temp))
        ) DO
            sorted_arr[j] := sorted_arr[j - gap];
            j := j - gap;
        END_WHILE;
        
        sorted_arr[j] := temp;
        i := i + 1;
    END_WHILE;
    
    gap := gap / 2;
END_WHILE;

(* Step 6: Final status setting (already set to success at initialization) *)
END_FUNCTION_BLOCK