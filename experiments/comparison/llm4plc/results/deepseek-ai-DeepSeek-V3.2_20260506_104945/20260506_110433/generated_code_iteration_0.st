START_ST
FUNCTION_BLOCK ShellSortFB
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
    state : INT; // 0=INIT, 1=SORTING, 2=COMPLETED, 3=ERROR
    prevState : INT;
    i : DINT;
    j : DINT;
    gap : DINT;
    temp : DINT;
    swapFlag : BOOL;
    N : CONSTANT := 1000;
    internalArray : ARRAY[1..1000] OF DINT;
END_VAR

CASE state OF
    0: // STATE 0: INITIALIZE
        // Copy input array to sorted_arr and internalArray
        FOR i := 1 TO N BY 1 DO
            sorted_arr[i] := arr[i];
            internalArray[i] := arr[i];
        END_FOR;
        
        // Perform array length validation (N is fixed at 1000)
        IF N <= 1 THEN
            error := TRUE;
            status := 16#8200; // Array size <= 1
            state := 3; // Transition to ERROR state
        ELSIF N > 1000 THEN
            error := TRUE;
            status := 16#8201; // Array size > 1000
            state := 3; // Transition to ERROR state
        ELSE
            error := FALSE;
            status := 16#0000; // No error
            state := 1; // Transition to SORTING state
            gap := N / 2; // Initialize gap for Shell Sort
            swapFlag := FALSE;
        END_IF;
        
    1: // STATE 1: SORTING
        // Perform Shell Sort algorithm
        IF gap > 0 THEN
            swapFlag := FALSE;
            i := gap + 1;
            WHILE i <= N DO
                temp := internalArray[i];
                j := i;
                
                // Compare and swap based on sortDirection
                IF NOT sortDirection THEN // Ascending order
                    WHILE (j > gap) AND (internalArray[j - gap] > temp) DO
                        internalArray[j] := internalArray[j - gap];
                        j := j - gap;
                        swapFlag := TRUE;
                    END_WHILE;
                ELSE // Descending order
                    WHILE (j > gap) AND (internalArray[j - gap] < temp) DO
                        internalArray[j] := internalArray[j - gap];
                        j := j - gap;
                        swapFlag := TRUE;
                    END_WHILE;
                END_IF;
                
                internalArray[j] := temp;
                i := i + 1;
            END_WHILE;
            
            // Reduce gap if no swaps occurred in this iteration
            IF NOT swapFlag THEN
                gap := gap / 2;
            END_IF;
        ELSE
            // Sorting completed, copy internalArray to sorted_arr
            FOR i := 1 TO N BY 1 DO
                sorted_arr[i] := internalArray[i];
            END_FOR;
            state := 2; // Transition to COMPLETED state
        END_IF;
        
    2: // STATE 2: COMPLETED
        // Maintain final outputs
        error := FALSE;
        status := 16#0000;
        // sorted_arr already contains sorted result
        // Remain in COMPLETED state
        state := 2;
        
    3: // STATE 3: ERROR
        // Maintain error outputs
        // sorted_arr already contains copy of input arr (unsorted)
        // Remain in ERROR state
        state := 3;
        
END_CASE;

prevState := state;
END_FUNCTION_BLOCK
END_ST