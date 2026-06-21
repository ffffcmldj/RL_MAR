FUNCTION_BLOCK FB_WarehouseManagement
    VAR_INPUT 
        requestIn : BOOL := FALSE;
        requestOut : BOOL := FALSE;
    END_VAR

    VAR_OUTPUT 
        productNum : INT := 0;
        libFreeNum : INT := 9;
        error : BOOL := FALSE;
        status : WORD := 16#0000;
    END_VAR

    VAR_IN_OUT 
        library : ARRAY[1..9] OF BOOL;
    END_VAR

    VAR 
        i : INT;
        found : BOOL := FALSE;
        errFull : WORD := 16#8001;
        errEmpty : WORD := 16#8002;
    END_VAR

    // Initialization
    IF NOT error THEN
        status := 16#0000; // Reset status
        // Initialize library if not already done
        i := 1;
        WHILE i <= 9 DO
            library[i] := FALSE; // Set all positions to available
            i := i + 1;
        END_WHILE
    END_IF

    // Product Storage Logic
    IF requestIn THEN
        found := FALSE;
        i := 9; // Start from highest index
        WHILE (i >= 1) AND (NOT found) DO
            IF NOT library[i] THEN // Check for free position
                library[i] := TRUE; // Mark as occupied
                productNum := productNum + 1; // Increment product count
                libFreeNum := libFreeNum - 1; // Decrement free positions
                found := TRUE; // Position found
            END_IF
            i := i - 1; // Move to the next lower index
        END_WHILE

        // Check for errors
        IF NOT found THEN
            error := TRUE; // No free position found
            status := errFull; // Set error status
        ELSIF productNum = 9 THEN
            error := TRUE; // Storage full
            status := errFull; // Set error status
        END_IF
    END_IF

    // Product Retrieval Logic
    IF requestOut THEN
        found := FALSE;
        i := 1; // Start from lowest index
        WHILE (i <= 9) AND (NOT found) DO
            IF library[i] THEN // Check for occupied position
                library[i] := FALSE; // Mark as available
                productNum := productNum - 1; // Decrement product count
                libFreeNum := libFreeNum + 1; // Increment free positions
                found := TRUE; // Position found
            END_IF
            i := i + 1; // Move to the next higher index
        END_WHILE

        // Check for errors
        IF NOT found THEN
            error := TRUE; // No occupied position found
            status := errEmpty; // Set error status
        ELSIF productNum < 0 THEN
            error := TRUE; // Invalid product count
            status := errEmpty; // Set error status
        END_IF
    END_IF
END_FUNCTION_BLOCK