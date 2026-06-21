FUNCTION_BLOCK SelectSort
    VAR_INPUT
        exe : BOOL;
        seq : ARRAY [0..99] OF INT; // Assuming the array is of type INT and has a fixed size of 100 elements
    END_VAR
    VAR_OUTPUT
        error : BOOL := FALSE;
        status : WORD := 16#0000;
    END_VAR
    VAR
        i, j, minIndex : INT;
        temp : INT; // Change temp to match the type of elements in seq
        isArray : BOOL := TRUE; // Since seq is declared as an array, this can be set to TRUE directly
    END_VAR

    // Execute sorting if exe is TRUE
    IF exe THEN
        FOR i := 0 TO 99 DO // Adjust loop to match the array size
            minIndex := i;
            FOR j := i + 1 TO 99 DO
                IF seq[j] < seq[minIndex] THEN
                    minIndex := j;
                END_IF
            END_FOR

            // Swap elements
            temp := seq[i];
            seq[i] := seq[minIndex];
            seq[minIndex] := temp;
        END_FOR

        // Set status to no error after sorting
        error := FALSE;
        status := 16#0000;
    END_IF
END_FUNCTION_BLOCK