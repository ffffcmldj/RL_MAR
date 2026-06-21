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
    // Internal state variables
    bExePrev : BOOL;
    bProcessing : BOOL;
    nArraySize : DINT;
    nMinIndex : DINT;
    nOuterIdx : DINT;
    nInnerIdx : DINT;
    // Temporary variant for element access
    tempVariant : VARIANT;
    // Flags for type identification
    bIsIntegerType : BOOL;
    bIsUnsignedType : BOOL;
    bIsRealType : BOOL;
    // Comparison results
    bLessThan : BOOL;
    bGreaterThan : BOOL;
    // Error handling
    bTypeCheckDone : BOOL;
    bArrayCheckDone : BOOL;
END_VAR

// Main execution logic
IF exe AND NOT bExePrev THEN
    // Rising edge of exe detected, start new sorting operation
    error := FALSE;
    status := 16#0000;
    bProcessing := TRUE;
    bTypeCheckDone := FALSE;
    bArrayCheckDone := FALSE;
    nOuterIdx := 0;
    nInnerIdx := 0;
    nMinIndex := 0;
    
    // Step 1: Check if seq is an array
    IF NOT __IS_ARRAY(seq) THEN
        error := TRUE;
        status := 16#8A01;
        bProcessing := FALSE;
        RETURN;
    END_IF;
    
    // Get array size
    nArraySize := __ARRAY_UPPER_BOUND(seq, 1) - __ARRAY_LOWER_BOUND(seq, 1) + 1;
    
    // Check if array size is valid (at least 2 elements for meaningful sort)
    IF nArraySize <= 1 THEN
        // Array is already sorted (0 or 1 element)
        bProcessing := FALSE;
        error := FALSE;
        status := 16#0000;
        RETURN;
    END_IF;
    
    // Determine array element type
    __GET_TYPE(seq, tempVariant);
    
    // Check if element type is supported
    CASE __TYPE_OF(tempVariant) OF
        __SINT_TYPE, __INT_TYPE, __DINT_TYPE, __LINT_TYPE,
        __USINT_TYPE, __UINT_TYPE, __UDINT_TYPE, __ULINT_TYPE,
        __REAL_TYPE, __LREAL_TYPE:
            // Supported types
            bIsIntegerType := (__TYPE_OF(tempVariant) >= __SINT_TYPE AND __TYPE_OF(tempVariant) <= __LINT_TYPE)
                              OR (__TYPE_OF(tempVariant) >= __USINT_TYPE AND __TYPE_OF(tempVariant) <= __ULINT_TYPE);
            bIsUnsignedType := (__TYPE_OF(tempVariant) >= __USINT_TYPE AND __TYPE_OF(tempVariant) <= __ULINT_TYPE);
            bIsRealType := (__TYPE_OF(tempVariant) = __REAL_TYPE) OR (__TYPE_OF(tempVariant) = __LREAL_TYPE);
            bTypeCheckDone := TRUE;
        ELSE
            // Unsupported type
            error := TRUE;
            status := 16#8A01; // Using same error code for invalid array type
            bProcessing := FALSE;
            RETURN;
    END_CASE;
    
    bArrayCheckDone := TRUE;
    
ELSIF NOT exe THEN
    // exe is FALSE, reset previous edge detection
    bExePrev := FALSE;
    
ELSIF bProcessing THEN
    // Continue sorting operation
    
    // Selection sort algorithm
    IF nOuterIdx < nArraySize - 1 THEN
        nMinIndex := nOuterIdx;
        nInnerIdx := nOuterIdx + 1;
        
        WHILE nInnerIdx < nArraySize DO
            // Compare elements at nMinIndex and nInnerIdx
            // Handle different data types appropriately
            
            IF bIsIntegerType THEN
                IF bIsUnsignedType THEN
                    // Unsigned integer comparison
                    CASE __TYPE_OF(tempVariant) OF
                        __USINT_TYPE: bLessThan := __GET_ELEMENT(seq, nMinIndex) > __GET_ELEMENT(seq, nInnerIdx);
                        __UINT_TYPE: bLessThan := __GET_ELEMENT(seq, nMinIndex) > __GET_ELEMENT(seq, nInnerIdx);
                        __UDINT_TYPE: bLessThan := __GET_ELEMENT(seq, nMinIndex) > __GET_ELEMENT(seq, nInnerIdx);
                        __ULINT_TYPE: bLessThan := __GET_ELEMENT(seq, nMinIndex) > __GET_ELEMENT(seq, nInnerIdx);
                    END_CASE;
                ELSE
                    // Signed integer comparison
                    CASE __TYPE_OF(tempVariant) OF
                        __SINT_TYPE: bLessThan := __GET_ELEMENT(seq, nMinIndex) > __GET_ELEMENT(seq, nInnerIdx);
                        __INT_TYPE: bLessThan := __GET_ELEMENT(seq, nMinIndex) > __GET_ELEMENT(seq, nInnerIdx);
                        __DINT_TYPE: bLessThan := __GET_ELEMENT(seq, nMinIndex) > __GET_ELEMENT(seq, nInnerIdx);
                        __LINT_TYPE: bLessThan := __GET_ELEMENT(seq, nMinIndex) > __GET_ELEMENT(seq, nInnerIdx);
                    END_CASE;
                END_IF;
            ELSIF bIsRealType THEN
                // Real number comparison
                CASE __TYPE_OF(tempVariant) OF
                    __REAL_TYPE: bLessThan := __GET_ELEMENT(seq, nMinIndex) > __GET_ELEMENT(seq, nInnerIdx);
                    __LREAL_TYPE: bLessThan := __GET_ELEMENT(seq, nMinIndex) > __GET_ELEMENT(seq, nInnerIdx);
                END_CASE;
            END_IF;
            
            IF bLessThan THEN
                nMinIndex := nInnerIdx;
            END_IF;
            
            nInnerIdx := nInnerIdx + 1;
        END_WHILE;
        
        // Swap elements if needed
        IF nMinIndex <> nOuterIdx THEN
            // Perform swap using temporary variable of appropriate type
            tempVariant := __GET_ELEMENT(seq, nOuterIdx);
            __SET_ELEMENT(seq, nOuterIdx, __GET_ELEMENT(seq, nMinIndex));
            __SET_ELEMENT(seq, nMinIndex, tempVariant);
        END_IF;
        
        nOuterIdx := nOuterIdx + 1;
    ELSE
        // Sorting completed
        bProcessing := FALSE;
        error := FALSE;
        status := 16#0000;
    END_IF;
END_IF;

// Store previous exe state for edge detection
bExePrev := exe;

// If not processing and no error, ensure outputs are correct
IF NOT bProcessing AND NOT error THEN
    error := FALSE;
    status := 16#0000;
END_IF;

END_FUNCTION_BLOCK
END_ST