START_ST
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
    state : INT := 0;
    bInitDone : BOOL := FALSE;
    i : INT;
    found : BOOL;
    errFull : WORD := 16#8001;
    errEmpty : WORD := 16#8002;
    tempProductNum : INT;
    tempLibFreeNum : INT;
END_VAR

CASE state OF
    0:
        (* INITIALIZATION STATE *)
        i := 1;
        WHILE i <= 9 DO
            library[i] := FALSE;
            i := i + 1;
        END_WHILE;
        productNum := 0;
        libFreeNum := 9;
        error := FALSE;
        status := 16#0000;
        bInitDone := TRUE;
        state := 1;

    1:
        (* PROCESSING STATE *)
        (* Reset error handling *)
        error := FALSE;
        status := 16#0000;

        (* Calculate current counts from library array *)
        tempProductNum := 0;
        i := 1;
        WHILE i <= 9 DO
            IF library[i] THEN
                tempProductNum := tempProductNum + 1;
            END_IF;
            i := i + 1;
        END_WHILE;
        tempLibFreeNum := 9 - tempProductNum;

        (* Handle concurrent requests *)
        IF requestIn AND NOT requestOut THEN
            (* Storage request only *)
            IF tempProductNum >= 9 THEN
                error := TRUE;
                status := errFull;
            ELSE
                i := 9;
                found := FALSE;
                WHILE i >= 1 AND NOT found DO
                    IF NOT library[i] THEN
                        library[i] := TRUE;
                        found := TRUE;
                    END_IF;
                    i := i - 1;
                END_WHILE;
                tempProductNum := tempProductNum + 1;
                tempLibFreeNum := 9 - tempProductNum;
            END_IF;

        ELSIF requestOut AND NOT requestIn THEN
            (* Retrieval request only *)
            IF tempProductNum <= 0 THEN
                error := TRUE;
                status := errEmpty;
            ELSE
                i := 1;
                found := FALSE;
                WHILE i <= 9 AND NOT found DO
                    IF library[i] THEN
                        library[i] := FALSE;
                        found := TRUE;
                    END_IF;
                    i := i + 1;
                END_WHILE;
                tempProductNum := tempProductNum - 1;
                tempLibFreeNum := 9 - tempProductNum;
            END_IF;

        ELSIF requestIn AND requestOut THEN
            (* Concurrent storage and retrieval requests *)
            (* Process storage first if possible *)
            IF tempProductNum >= 9 THEN
                error := TRUE;
                status := errFull;
            ELSE
                i := 9;
                found := FALSE;
                WHILE i >= 1 AND NOT found DO
                    IF NOT library[i] THEN
                        library[i] := TRUE;
                        found := TRUE;
                    END_IF;
                    i := i - 1;
                END_WHILE;
                tempProductNum := tempProductNum + 1;
                tempLibFreeNum := 9 - tempProductNum;
            END_IF;

            (* Process retrieval if possible (even if storage error occurred) *)
            IF tempProductNum <= 0 THEN
                error := TRUE;
                status := errEmpty;
            ELSE
                i := 1;
                found := FALSE;
                WHILE i <= 9 AND NOT found DO
                    IF library[i] THEN
                        library[i] := FALSE;
                        found := TRUE;
                    END_IF;
                    i := i + 1;
                END_WHILE;
                tempProductNum := tempProductNum - 1;
                tempLibFreeNum := 9 - tempProductNum;
            END_IF;
        END_IF;

        (* Update outputs *)
        productNum := tempProductNum;
        libFreeNum := tempLibFreeNum;

        (* Remain in processing state *)
        state := 1;
END_CASE;
END_FUNCTION_BLOCK
END_ST