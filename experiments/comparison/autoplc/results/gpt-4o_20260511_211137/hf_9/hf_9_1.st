FUNCTION_BLOCK ShellSortFB
    VAR_INPUT
        sortDirection : BOOL; // FALSE for ascending, TRUE for descending
        arr : ARRAY[1..1000] OF DINT; // Input array to be sorted
    END_VAR
    VAR_OUTPUT
        error : BOOL; // TRUE if an error occurred, FALSE otherwise
        status : WORD; // Status code
        sorted_arr : ARRAY[1..1000] OF DINT; // Sorted output array
    END_VAR
    VAR
        N : INT := 1000; // Fixed size of the array
        gap, i, j : INT; // Loop variables for sorting
        temp : DINT; // Temporary variable for swapping
    END_VAR

    // Step 1: Copy input array to output array
    FOR i := 1 TO N DO
        sorted_arr[i] := arr[i];
    END_FOR

    // Step 2: Check array length
    IF N <= 1 THEN
        error := TRUE;
        status := 16#8200; // Array size is <= 1
        RETURN;
    ELSIF N > 1000 THEN
        error := TRUE;
        status := 16#8201; // Array size is > 1000
        RETURN;
    ELSE
        error := FALSE;
        status := 16#0000; // No error
    END_IF

    // Step 3: Shell Sort
    gap := N / 2;
    WHILE gap > 0 DO
        FOR i := gap + 1 TO N DO
            temp := sorted_arr[i];
            j := i;
            IF NOT sortDirection THEN
                // Ascending order
                WHILE (j > gap) AND (sorted_arr[j - gap] > temp) DO
                    sorted_arr[j] := sorted_arr[j - gap];
                    j := j - gap;
                END_WHILE
            ELSE
                // Descending order
                WHILE (j > gap) AND (sorted_arr[j - gap] < temp) DO
                    sorted_arr[j] := sorted_arr[j - gap];
                    j := j - gap;
                END_WHILE
            END_IF
            sorted_arr[j] := temp;
        END_FOR
        gap := gap / 2;
    END_WHILE

    // Step 4: Output handling
    // Error and status are already set appropriately
END_FUNCTION_BLOCK