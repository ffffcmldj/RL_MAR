ructured-text
FUNCTION_BLOCK SelectSort
VAR_INPUT
    exe : BOOL;
    seq : VARIANT;
END_VAR
VAR_OUTPUT
    error : BOOL;
    status : WORD;
END_VAR
VAR
    arrayLength : INT; // Length of the array
    i : INT; // Loop variable for outer loop
    j : INT; // Loop variable for inner loop
    temp : VARIANT; // Temporary variable for swapping
    isArray : BOOL; // Flag to check if seq is an array type
END_VAR

// State initialization
IF exe THEN
    error := FALSE;
    status := 16#0000; // No error
    isArray := FALSE;

    // Check if seq is an array type
    IF (TypeOf(seq) = ARRAY) THEN
        isArray := TRUE;
        arrayLength := ARRAY_LENGTH(seq); // Get the length of the array
    ELSE
        error := TRUE;
        status := 16#8A01; // Invalid array type
    END_IF;

    // Perform sorting if seq is a valid array type
    IF isArray THEN
        // Selection sort algorithm
        FOR i := 0 TO arrayLength - 2 DO
            // Assume the minimum is the first element
            VAR minIndex : INT := i;
            FOR j := i + 1 TO arrayLength - 1 DO
                // Find the minimum element in the unsorted array
                IF seq[j] < seq[minIndex] THEN
                    minIndex := j;
                END_IF;
            END_FOR;

            // Swap the found minimum element with the first element
            IF minIndex <> i THEN
                temp := seq[i];
                seq[i] := seq[minIndex];
                seq[minIndex] := temp;
            END_IF;
        END_FOR;
    END_IF;

    // Finalize sorting process
    IF NOT error THEN
        error := FALSE;
        status := 16#0000; // No error
    END_IF;
END_IF;

END_FUNCTION_BLOCK