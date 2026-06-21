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
    // Internal state variables
    bExecuted : BOOL := FALSE;
    nArraySize : DINT := 0;
    nOuterIdx : DINT := 0;
    nInnerIdx : DINT := 0;
    nMinIdx : DINT := 0;
    bIsArray : BOOL := FALSE;
    bSortingComplete : BOOL := FALSE;
    
    // Temporary variables for comparison and swapping
    tempVariant : VARIANT;
    bLessThan : BOOL;
    bEqual : BOOL;
END_VAR

// Reset outputs when not executing
IF NOT exe THEN
    bExecuted := FALSE;
    bSortingComplete := FALSE;
    RETURN;
END_IF

// Execute only once per rising edge of exe
IF exe AND NOT bExecuted THEN
    bExecuted := TRUE;
    error := FALSE;
    status := 16#0000;
    
    // Check if seq is an array type
    bIsArray := __ISVARIANT(seq) AND __QUERYVARIANT(seq, 'IS_ARRAY');
    
    IF NOT bIsArray THEN
        error := TRUE;
        status := 16#8A01;
        bSortingComplete := TRUE;
        RETURN;
    END_IF
    
    // Get array size
    nArraySize := __QUERYVARIANT(seq, 'ARRAY_SIZE');
    
    // Initialize sorting variables
    nOuterIdx := 0;
    nMinIdx := 0;
    nInnerIdx := 0;
    bSortingComplete := FALSE;
END_IF

// Perform selection sort algorithm
IF bExecuted AND NOT bSortingComplete THEN
    // Outer loop: from first element to second-last
    FOR nOuterIdx := 0 TO nArraySize - 2 DO
        // Assume current position is minimum
        nMinIdx := nOuterIdx;
        
        // Inner loop: find minimum in remaining array
        FOR nInnerIdx := nOuterIdx + 1 TO nArraySize - 1 DO
            // Compare elements at nInnerIdx and nMinIdx
            // Get element at nInnerIdx
            __GETVARIANT(seq, nInnerIdx, tempVariant);
            
            // Compare with element at nMinIdx
            bLessThan := __COMPAREVARIANT(tempVariant, seq, nMinIdx, '<');
            
            IF bLessThan THEN
                nMinIdx := nInnerIdx;
            END_IF
        END_FOR
        
        // Swap elements if minimum is not at current position
        IF nMinIdx <> nOuterIdx THEN
            // Swap elements at nOuterIdx and nMinIdx
            __GETVARIANT(seq, nOuterIdx, tempVariant);
            __GETVARIANT(seq, nMinIdx, seq, nOuterIdx);
            __SETVARIANT(seq, nMinIdx, tempVariant);
        END_IF
    END_FOR
    
    // Sorting complete
    bSortingComplete := TRUE;
    error := FALSE;
    status := 16#0000;
END_IF

// Reset execution flag when sorting is complete
IF bSortingComplete THEN
    bExecuted := FALSE;
END_IF
END_FUNCTION_BLOCK