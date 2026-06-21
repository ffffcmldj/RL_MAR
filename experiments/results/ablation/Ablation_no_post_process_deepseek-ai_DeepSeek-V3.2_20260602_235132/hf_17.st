TYPE
    ST_WarehouseStatus :
        STRUCT
            productNum : INT;
            libFreeNum : INT;
            error : BOOL;
            status : WORD;
        END_STRUCT;
    ARRAY_StoragePositions : ARRAY[1..9] OF BOOL;
END_TYPE

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
    library : ARRAY_StoragePositions;
END_VAR

VAR
    i : INT;
    found : BOOL;
    errFull : WORD := 16#8001;
    errEmpty : WORD := 16#8002;
    initDone : BOOL := FALSE;
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
    initDone := TRUE;
END_IF;

(* Calculate current product count and free positions *)
productNum := 0;
i := 1;
WHILE i <= 9 DO
    IF library[i] THEN
        productNum := productNum + 1;
    END_IF;
    i := i + 1;
END_WHILE;
libFreeNum := 9 - productNum;

(* Handle product storage request *)
IF requestIn THEN
    (* Check for storage full condition *)
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
                found := TRUE;
            END_IF;
            i := i - 1;
        END_WHILE;
        
        (* Update counters if position was found *)
        IF found THEN
            productNum := productNum + 1;
            libFreeNum := libFreeNum - 1;
        END_IF;
    END_IF;
END_IF;

(* Handle product retrieval request *)
IF requestOut THEN
    (* Check for storage empty condition *)
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
                found := TRUE;
            END_IF;
            i := i + 1;
        END_WHILE;
        
        (* Update counters if position was found *)
        IF found THEN
            productNum := productNum - 1;
            libFreeNum := libFreeNum + 1;
        END_IF;
    END_IF;
END_IF;

(* Validate counter consistency - safety check *)
IF (productNum + libFreeNum) <> 9 THEN
    error := TRUE;
    status := 16#8003;  (* Internal consistency error *)
END_IF;

END_FUNCTION_BLOCK