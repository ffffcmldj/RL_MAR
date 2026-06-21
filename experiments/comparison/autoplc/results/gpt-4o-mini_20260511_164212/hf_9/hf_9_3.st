FUNCTION_BLOCK hf_9
VAR_INPUT
    sortDirection : BOOL; // FALSE for ascending, TRUE for descending
    arr : ARRAY[1..1000] OF DINT; // Input array to be sorted
END_VAR_INPUT

VAR_OUTPUT
    error : BOOL; // TRUE if an error occurred, FALSE otherwise
    status : WORD; // Status code
    sorted_arr : ARRAY[1..1000] OF DINT; // Output sorted array
END_VAR_OUTPUT

VAR
    i, j, gap : INT; // Loop variables
    temp : DINT; // Temporary variable for swapping
END_VAR

// Initialization
error := FALSE;
status := 16#0000; // No error
// Check the array length
IF (1000 <= 1) THEN
    error := TRUE;
    status := 16#8200; // Array size is <= 1
ELSIF (1000 > 1000) THEN
    error := TRUE;
    status := 16#8201; // Array size is > 1000
ELSE
    // Copy input array to sorted_arr
    FOR i := 1 TO 1000 DO
        sorted_arr[i] := arr[i];
    END_FOR;

    // Shell Sort implementation
    gap := 500; // Initial gap
    WHILE gap > 0 DO
        FOR i := gap + 1 TO 1000 DO
            temp := sorted_arr[i];
            j := i;
            // Sort in ascending or descending order based on sortDirection
            IF NOT sortDirection THEN // Ascending
                WHILE (j > gap) AND (sorted_arr[j - gap] > temp) DO
                    sorted_arr[j] := sorted_arr[j - gap];
                    j := j - gap;
                END_WHILE;
            ELSE // Descending
                WHILE (j > gap) AND (sorted_arr[j - gap] < temp) DO
                    sorted_arr[j] := sorted_arr[j - gap];
                    j := j - gap;
                END_WHILE;
            END_IF;
            sorted_arr[j] := temp;
        END_FOR;
        gap := gap DIV 2; // Reduce gap
    END_WHILE;
END_IF;

END_FUNCTION_BLOCK