START_REASON
The feedback indicates that the code passed ANTLR syntax validation but failed CODESYS compiler validation due to the use of an unknown type, `VARIANT`. The `VARIANT` type is not recognized in CODESYS, which likely caused the validation error. To resolve this, I will replace the `VARIANT` type with a more appropriate and recognized type, such as `ARRAY OF INT` or `ARRAY OF REAL`, depending on the intended data type for the array. Additionally, I will ensure the built-in functions (`__IS_ARRAY` and `__ARRAY_LEN`) are replaced with valid alternatives or implemented manually if necessary.
END_REASON

START_ST
FUNCTION_BLOCK SelectSort
VAR_INPUT
    exe : BOOL; // Start sorting
    seq : ARRAY [1..100] OF INT; // Array to be sorted (fixed size for simplicity)
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
    temp : INT; // Temporary variable for swapping elements
    arrayLength : INT := 0; // Length of the input array
    isValidArray : BOOL := TRUE; // Flag indicating if the input is a valid array
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
        // Validate array length (assuming non-zero length is valid)
        arrayLength := SIZEOF(seq) / SIZEOF(seq[1]); // Calculate array length
        IF arrayLength = 0 THEN
            isValidArray := FALSE;
        END_IF;

        IF NOT isValidArray THEN
            state := 3; // Transition to SET ERROR STATUS state
        ELSE
            state := 2; // Transition to SORT ARRAY state
        END_IF;

    // STATE 2: SORT ARRAY
    2:
        // Selection sort algorithm
        FOR i := 1 TO arrayLength - 1 DO
            minIndex := i; // Assume the current index is the smallest
            FOR j := i + 1 TO arrayLength DO
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
        status := 16#8A01; // Invalid array type or length status code
        state := 0; // Transition back to IDLE state

    // STATE 4: SET SUCCESS STATUS
    4:
        error := FALSE; // Clear error flag
        status := 16#0000; // Success status code
        state := 0; // Transition back to IDLE state

END_CASE;
END_FUNCTION_BLOCK
END_ST