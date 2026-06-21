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
    initDone : BOOL := FALSE;
    errFull : WORD := 16#8001;
    errEmpty : WORD := 16#8002;
END_VAR

    (* Reset error status at start of each cycle *)
    error := FALSE;
    status := 16#0000;

    (* Initialize library array on first execution *)
    IF NOT initDone THEN
        i := 1;
        WHILE i <= 9 DO
            library[i] := FALSE;
            i := i + 1;
        END_WHILE;
        productNum := 0;
        libFreeNum := 9;
        initDone := TRUE;
    END_IF;

    (* Handle storage request *)
    IF requestIn THEN
        (* Check if storage is full *)
        IF productNum >= 9 THEN
            error := TRUE;
            status := errFull;
        ELSE
            (* Search for free position from highest to lowest index (FILO) *)
            found := FALSE;
            i := 9;
            WHILE i >= 1 AND NOT found DO
                IF NOT library[i] THEN
                    library[i] := TRUE;
                    productNum := productNum + 1;
                    libFreeNum := libFreeNum - 1;
                    found := TRUE;
                END_IF;
                i := i - 1;
            END_WHILE;
            
            (* If no free position found despite productNum < 9, set error *)
            IF NOT found THEN
                error := TRUE;
                status := errFull;
            END_IF;
        END_IF;
    END_IF;

    (* Handle retrieval request *)
    IF requestOut THEN
        (* Check if storage is empty *)
        IF productNum <= 0 THEN
            error := TRUE;
            status := errEmpty;
        ELSE
            (* Search for occupied position from lowest to highest index (FIFO) *)
            found := FALSE;
            i := 1;
            WHILE i <= 9 AND NOT found DO
                IF library[i] THEN
                    library[i] := FALSE;
                    productNum := productNum - 1;
                    libFreeNum := libFreeNum + 1;
                    found := TRUE;
                END_IF;
                i := i + 1;
            END_WHILE;
            
            (* If no occupied position found despite productNum > 0, set error *)
            IF NOT found THEN
                error := TRUE;
                status := errEmpty;
            END_IF;
        END_IF;
    END_IF;

    (* Final consistency check *)
    IF (productNum + libFreeNum) <> 9 THEN
        error := TRUE;
        (* Keep existing status if already set, otherwise set to general error *)
        IF status = 16#0000 THEN
            status := 16#8003;
        END_IF;
    END_IF;

END_FUNCTION_BLOCK