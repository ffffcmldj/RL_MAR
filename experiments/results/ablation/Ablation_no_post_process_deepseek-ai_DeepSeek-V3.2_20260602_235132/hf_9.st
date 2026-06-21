TYPE
    // Direction enumeration for clarity
    SortDirectionEnum : (Ascending, Descending);
END_TYPE

FUNCTION_BLOCK ShellSortFB
VAR_INPUT
    // Input array to be sorted (fixed size 1000)
    arr : ARRAY[1..1000] OF DINT;
    // FALSE = Ascending, TRUE = Descending
    sortDirection : BOOL;
END_VAR
VAR_OUTPUT
    // Sorted output array
    sorted_arr : ARRAY[1..1000] OF DINT;
    // Error flag (TRUE = error occurred)
    error : BOOL;
    // Status code (16#0000 = OK)
    status : WORD;
END_VAR
VAR
    // Algorithm variables
    i : DINT;
    j : DINT;
    gap : DINT;
    temp : DINT;
    // Fixed array size constant
    n : DINT := 1000;
    // Internal direction flag (TRUE = sort ascending)
    sortAscending : BOOL;
END_VAR

// 1. Copy input array to output array
sorted_arr := arr;

// 2. Initialize outputs to default values
error := FALSE;
status := 16#0000;

// 3. Validate array size (fixed at 1000, but checks maintained for robustness)
IF n <= 1 THEN
    error := TRUE;
    status := 16#8200;  // Array size ≤ 1
    RETURN;
END_IF;

IF n > 1000 THEN
    error := TRUE;
    status := 16#8201;  // Array size > 1000
    RETURN;
END_IF;

// 4. Determine sort direction
// sortDirection = FALSE → Ascending → sortAscending = TRUE
// sortDirection = TRUE → Descending → sortAscending = FALSE
sortAscending := NOT sortDirection;

// 5. Shell Sort Algorithm
gap := n / 2;  // Initial gap size

WHILE gap > 0 DO
    i := gap + 1;  // Start from first element after gap
    
    WHILE i <= n DO
        temp := sorted_arr[i];
        j := i;
        
        // Inner loop: insertion sort for current gap
        WHILE (j > gap) AND (
            (sortAscending AND (sorted_arr[j - gap] > temp)) OR
            (NOT sortAscending AND (sorted_arr[j - gap] < temp))
        ) DO
            sorted_arr[j] := sorted_arr[j - gap];
            j := j - gap;
        END_WHILE;
        
        sorted_arr[j] := temp;
        i := i + 1;
    END_WHILE;
    
    gap := gap / 2;  // Reduce gap
END_WHILE;

// 6. Successful completion
error := FALSE;
status := 16#0000;

END_FUNCTION_BLOCK;