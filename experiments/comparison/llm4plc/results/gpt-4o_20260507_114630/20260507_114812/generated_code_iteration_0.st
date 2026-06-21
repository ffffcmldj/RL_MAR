plaintext
START_ST
FUNCTION_BLOCK SelectSort
VAR_INPUT
    exe : BOOL; // Start sorting
    seq : VARIANT; // Array to be sorted
END_VAR
VAR_OUTPUT
    error : BOOL; // Error status
    status : WORD; // Status code
END_VAR
VAR
    state : INT := 0; // Current state of the FSM
    prevState : INT := 0; // Previous state of the FSM
    i : INT := 0; // Outer loop index for selection sort
    j : INT := 0; // Inner loop index for selection sort
    minIndex : INT := 0; // Index of the smallest element in the unsorted portion
    temp : VARIANT; // Temporary variable for swapping elements
    arrayLength : INT := 0; // Length of the input array
    isValidArray : BOOL := FALSE; // Flag indicating if the input is a valid array
END_VAR

// Main logic
CASE state OF
    // STATE 0: IDLE
    0:
        error := FALSE; // Default error state
        status := 16#0000; // Default status code
        IF exe THEN
            state := 1; // Transition to VALIDATE INPUT state
        END_IF;

    // STATE 1: VALIDATE INPUT
    1:
        // Check if seq is an array
        isValidArray := __IS_ARRAY(seq); // Built-in function to check if seq is an array
        IF NOT isValidArray THEN
            state := 3; // Transition to SET ERROR STATUS state
        ELSE
            arrayLength := __ARRAY_LEN(seq); // Get the length of the array
            state := 2; // Transition to SORT ARRAY state
        END_IF;

    // STATE 2: SORT ARRAY
    2:
        // Selection sort algorithm
        FOR i := 0 TO arrayLength - 2 DO
            minIndex := i; // Assume the current index is the smallest
            FOR j := i + 1 TO arrayLength - 1 DO
                IF seq[j] < seq[minIndex] THEN
                    minIndex := j; // Update minIndex if a smaller element is found
                END_IF;
            END_FOR;
            // Swap elements if minIndex is different from i
            IF minIndex <> i THEN
                temp := seq[i];
                seq[i] := seq[minIndex];
                seq[minIndex] := temp;
            END_IF;
        END_FOR;
        state := 4; // Transition to SET SUCCESS STATUS state

    // STATE 3: SET ERROR STATUS
    3:
        error := TRUE; // Set error flag
        status := 16#8A01; // Invalid array type status code
        state := 0; // Transition back to IDLE state

    // STATE 4: SET SUCCESS STATUS
    4:
        error := FALSE; // Clear error flag
        status := 16#0000; // Success status code
        state := 0; // Transition back to IDLE state

END_CASE;
END_FUNCTION_BLOCK
END_ST