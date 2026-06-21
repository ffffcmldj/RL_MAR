FUNCTION_BLOCK FB_ShellSort
VAR_INPUT
    sortDirection : BOOL; // FALSE = ascending, TRUE = descending
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
    n : DINT := 1000; // Fixed array size
    ascending : BOOL;
END_VAR

// Initialize outputs
error := FALSE;
status := 16#0000;

// Copy input array to output array
FOR i := 1 TO n DO
    sorted_arr[i] := arr[i];
END_FOR;

// Array size validation
IF n <= 1 THEN
    error := TRUE;
    status := 16#8200;
    RETURN;
END_IF;

IF n > 1000 THEN
    error := TRUE;
    status := 16#8201;
    RETURN;
END_IF;

// Determine sort direction
ascending := NOT sortDirection; // FALSE = ascending, TRUE = descending

// Shell Sort implementation
gap := n / 2;
WHILE gap > 0 DO
    FOR i := gap + 1 TO n DO
        temp := sorted_arr[i];
        j := i;
        
        // Inner loop with direction check
        WHILE (j > gap) AND 
              ((ascending AND (sorted_arr[j - gap] > temp)) OR 
               (NOT ascending AND (sorted_arr[j - gap] < temp))) DO
            sorted_arr[j] := sorted_arr[j - gap];
            j := j - gap;
        END_WHILE;
        
        sorted_arr[j] := temp;
    END_FOR;
    
    gap := gap / 2;
END_WHILE;

// Set success status if no errors occurred
IF NOT error THEN
    status := 16#0000;
END_IF;