START_ST
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
    state : INT; // FSM State (0: Init/Validate, 1: Sorting, 2: Done)
    arrayType : BOOL; // Helper: Is seq an array?
    arraySize : INT; // Helper: Size of array
    sorted : BOOL; // Helper: Is array sorted?
    tempVar : VARIANT; // Helper: For swapping elements
    minIndex : INT; // Helper: Index of minimum element
    loopIndex : INT; // Helper: Current iteration of selection sort
    i, j : INT; // Loop counters
    currentVal : VARIANT; // Helper to hold current array element
    minVal : VARIANT; // Helper to hold minimum value found
    minValIndex : INT; // Helper to hold index of minimum value
    isSortedCheck : BOOL; // Helper for sorted check
BEGIN
    // --- STATE MACHINE LOGIC ---
    
    // STATE 0: INITIALIZE / VALIDATE ARRAY TYPE
    IF state = 0 THEN
        IF exe = TRUE THEN
            // Check if seq is an array
            arrayType := (seq.VariantType = vtArray);
            
            IF arrayType = FALSE THEN
                // Invalid array type
                error := TRUE;
                status := 16#8A01;
                state := 0; // Stay in state 0 until exe is false or reset
            ELSE
                // Valid array, proceed to sorting
                error := FALSE;
                status := 0;
                state := 1;
            END_IF;
        ELSE
            // exe is FALSE, wait for trigger
            error := FALSE;
            status := 0;
            state := 0;
        END_IF;
    END_IF;

    // STATE 1: PERFORM SELECTION SORT
    IF state = 1 THEN
        IF exe = TRUE THEN
            // Get array size
            arraySize := seq.VariantSize;
            
            // Check if array is empty
            IF arraySize = 0 THEN
                sorted := TRUE;
            ELSE
                // Check if already sorted to optimize
                isSortedCheck := TRUE;
                FOR i := 0 TO arraySize - 2 DO
                    IF seq[i] > seq[i+1] THEN
                        isSortedCheck := FALSE;
                        EXIT;
                    END_IF;
                END_FOR;
                
                IF isSortedCheck = TRUE THEN
                    sorted := TRUE;
                ELSE
                    sorted := FALSE;
                    // Perform Selection Sort
                    FOR loopIndex := 0 TO arraySize - 2 DO
                        // Find minimum element in unsorted portion
                        minValIndex := loopIndex;
                        minVal := seq[loopIndex];
                        
                        FOR j := loopIndex + 1 TO arraySize - 1 DO
                            IF seq[j] < minVal THEN
                                minVal := seq[j];
                                minValIndex := j;
                            END_IF;
                        END_FOR;
                        
                        // Swap if minimum is not at the current position
                        IF minValIndex <> loopIndex THEN
                            currentVal := seq[loopIndex];
                            seq[loopIndex] := minVal;
                            seq[minValIndex] := currentVal;
                        END_IF;
                    END_FOR;
                    sorted := TRUE;
                END_IF;
            END_IF;
            
            // Transition logic based on sort completion
            IF sorted = TRUE THEN
                state := 2;
            ELSE
                // If not sorted, we rely on the loop logic above. 
                // However, strictly following the FSM "one operation per state" rule:
                // The operation "Perform Selection Sort" is atomic in this context because
                // the FOR loop executes to completion within one PLC scan cycle.
                // Once the loop finishes, we transition to State 2.
                // The variable 'sorted' is set to TRUE inside the loop logic above.
                state := 2; 
            END_IF;
        ELSE
            // exe is FALSE, stay in state 1 but do nothing
            state := 1;
        END_IF;
    END_IF;

    // STATE 2: COMPLETE SORT
    IF state = 2 THEN
        error := FALSE;
        status := 16#0000;
    END_IF;

END_FUNCTION_BLOCK
END_ST