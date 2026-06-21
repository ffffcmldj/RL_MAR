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
    n : DINT;
    ascending : BOOL;
    compareCondition : BOOL;
END_VAR

(* Initialize outputs *)
error := FALSE;
status := 16#0000;
sorted_arr := arr;
n := 1000;

(* Fixed size validation - N is fixed at 1000 *)
IF n <= 1 THEN
    error := TRUE;
    status := 16#8200;
    RETURN;
ELSIF n > 1000 THEN
    error := TRUE;
    status := 16#8201;
    RETURN;
END_IF;

(* Determine sort order: FALSE = Ascending, TRUE = Descending *)
ascending := NOT sortDirection;

(* Shell Sort Algorithm *)
gap := n / 2;
WHILE gap > 0 DO
    i := gap + 1;
    WHILE i <= n DO
        temp := sorted_arr[i];
        j := i;
        
        (* Determine comparison condition based on sort direction *)
        IF ascending THEN
            compareCondition := (j > gap) AND (sorted_arr[j - gap] > temp);
        ELSE
            compareCondition := (j > gap) AND (sorted_arr[j - gap] < temp);
        END_IF;
        
        WHILE compareCondition DO
            sorted_arr[j] := sorted_arr[j - gap];
            j := j - gap;
            
            (* Update comparison condition for next iteration *)
            IF ascending THEN
                compareCondition := (j > gap) AND (sorted_arr[j - gap] > temp);
            ELSE
                compareCondition := (j > gap) AND (sorted_arr[j - gap] < temp);
            END_IF;
        END_WHILE;
        
        sorted_arr[j] := temp;
        i := i + 1;
    END_WHILE;
    gap := gap / 2;
END_WHILE;
END_FUNCTION_BLOCK