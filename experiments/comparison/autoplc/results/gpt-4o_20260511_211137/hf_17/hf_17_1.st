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
        found : BOOL;
        errFull : WORD := 16#8001;
        errEmpty : WORD := 16#8002;
    END_VAR

    // Initialization of storage positions
    IF NOT (requestIn OR requestOut) THEN
        i := 1;
        WHILE i <= 9 DO
            library[i] := FALSE;
            i := i + 1;
        END_WHILE
        productNum := 0;
        libFreeNum := 9;
    END_IF

    // Reset error flag and status code at the start of each cycle
    error := FALSE;
    status := 16#0000;

    // Product Storage Logic
    IF requestIn THEN
        found := FALSE;
        i := 9;
        WHILE (i >= 1) AND NOT found DO
            IF NOT library[i] THEN
                library[i] := TRUE;
                productNum := productNum + 1;
                libFreeNum := libFreeNum - 1;
                found := TRUE;
            END_IF
            i := i - 1;
        END_WHILE

        IF NOT found THEN
            error := TRUE;
            status := errFull;
        END_IF
    END_IF

    // Product Retrieval Logic
    IF requestOut THEN
        found := FALSE;
        i := 1;
        WHILE (i <= 9) AND NOT found DO
            IF library[i] THEN
                library[i] := FALSE;
                productNum := productNum - 1;
                libFreeNum := libFreeNum + 1;
                found := TRUE;
            END_IF
            i := i + 1;
        END_WHILE

        IF NOT found THEN
            error := TRUE;
            status := errEmpty;
        END_IF
    END_IF

    // Ensure the sum of productNum and libFreeNum always equals 9
    IF (productNum + libFreeNum) <> 9 THEN
        // This should not happen if logic is correct
        // Handle unexpected state
    END_IF
END_FUNCTION_BLOCK