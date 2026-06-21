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
    tempProductNum : INT;
    tempLibFreeNum : INT;
END_VAR

    // Reset error status at start of each cycle
    error := FALSE;
    status := 16#0000;
    
    // Calculate current product count and free positions from library array
    tempProductNum := 0;
    tempLibFreeNum := 0;
    
    i := 1;
    WHILE i <= 9 DO
        IF library[i] THEN
            tempProductNum := tempProductNum + 1;
        ELSE
            tempLibFreeNum := tempLibFreeNum + 1;
        END_IF;
        i := i + 1;
    END_WHILE;
    
    // Update output variables with calculated values
    productNum := tempProductNum;
    libFreeNum := tempLibFreeNum;
    
    // Handle product storage request
    IF requestIn THEN
        // Check if storage is full
        IF productNum >= 9 THEN
            error := TRUE;
            status := errFull;
        ELSE
            // Search for free position from highest to lowest index
            found := FALSE;
            i := 9;
            WHILE i >= 1 AND NOT found DO
                IF NOT library[i] THEN
                    // Found free position
                    library[i] := TRUE;
                    found := TRUE;
                END_IF;
                i := i - 1;
            END_WHILE;
            
            // Update counters if position was found
            IF found THEN
                productNum := productNum + 1;
                libFreeNum := libFreeNum - 1;
            ELSE
                // This should not happen if productNum < 9, but handle as error
                error := TRUE;
                status := errFull;
            END_IF;
        END_IF;
    END_IF;
    
    // Handle product retrieval request
    IF requestOut THEN
        // Check if storage is empty
        IF productNum <= 0 THEN
            error := TRUE;
            status := errEmpty;
        ELSE
            // Search for occupied position from lowest to highest index
            found := FALSE;
            i := 1;
            WHILE i <= 9 AND NOT found DO
                IF library[i] THEN
                    // Found occupied position
                    library[i] := FALSE;
                    found := TRUE;
                END_IF;
                i := i + 1;
            END_WHILE;
            
            // Update counters if position was found
            IF found THEN
                productNum := productNum - 1;
                libFreeNum := libFreeNum + 1;
            ELSE
                // This should not happen if productNum > 0, but handle as error
                error := TRUE;
                status := errEmpty;
            END_IF;
        END_IF;
    END_IF;
    
    // Ensure consistency between productNum and libFreeNum
    // This is already maintained by the update logic above
    
END_FUNCTION_BLOCK