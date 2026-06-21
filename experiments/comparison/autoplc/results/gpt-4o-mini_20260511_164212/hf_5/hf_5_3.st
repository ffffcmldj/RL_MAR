FUNCTION_BLOCK SelectSort
VAR_INPUT
    exe : BOOL;                      // Trigger to start sorting
    seq : ARRAY[0..10] OF INT;      // Array to be sorted (replace 10 with the actual size)
END_VAR

VAR_OUTPUT
    error : BOOL;                   // Indicates if an error occurred
    status : WORD;                  // Status code reflecting the outcome
END_VAR

VAR
    arrayLength : INT;              // Length of the array
    i : INT;                        // Loop variable for outer loop
    j : INT;                        // Loop variable for inner loop
    minIndex : INT;                 // Index of the minimum element
    temp : INT;                     // Temporary variable for swapping
END_VAR

// Initialization
error := FALSE;                     // Default to no error
status := 16#0000;                 // Default status code

IF exe THEN
    // Get the length of the array
    arrayLength := SIZEOF(seq) / SIZEOF(seq[0]); // Calculate the length of the array
    
    // Selection sort algorithm
    FOR i := 0 TO arrayLength - 2 DO
        minIndex := i; // Assume the first element is the minimum
        
        FOR j := i + 1 TO arrayLength - 1 DO
            // Compare and find the minimum element
            IF seq[j] < seq[minIndex] THEN
                minIndex := j; // Update minIndex if a smaller element is found
            END_IF
        END_FOR
        
        // Swap the found minimum element with the first unsorted element
        IF minIndex <> i THEN
            temp := seq[i];
            seq[i] := seq[minIndex];
            seq[minIndex] := temp;
        END_IF
    END_FOR
    
    // Sorting completed successfully
    error := FALSE;
    status := 16#0000; // No error
END_IF

END_FUNCTION_BLOCK