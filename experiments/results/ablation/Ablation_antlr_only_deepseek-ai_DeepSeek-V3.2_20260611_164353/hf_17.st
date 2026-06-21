TYPE
    E_ErrorCode : WORD := 16#0000;
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
    status : E_ErrorCode := 16#0000;
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

(* Initialization - Execute once on first cycle *)
IF NOT initDone THEN
    i := 1;
    WHILE i <= 9 DO
        library[i] := FALSE;
        i := i + 1;
    END_WHILE;
    productNum := 0;
    libFreeNum := 9;
    error := FALSE;
    status := 16#0000;
    initDone := TRUE;
END_IF;

(* Reset error state at start of each cycle *)
error := FALSE;
status := 16#0000;

(* Handle concurrent requests: Input has priority over Output *)
IF requestIn THEN
    (* Storage Full Check *)
    IF productNum >= 9 THEN
        error := TRUE;
        status := errFull;
    ELSE
        (* Search for free position from highest to lowest (9→1) *)
        i := 9;
        found := FALSE;
        WHILE i >= 1 AND NOT found DO
            IF NOT library[i] THEN
                library[i] := TRUE;
                productNum := productNum + 1;
                libFreeNum := libFreeNum - 1;
                found := TRUE;
            END_IF;
            i := i - 1;
        END_WHILE;
        
        (* Verify search succeeded - safety fallback *)
        IF NOT found THEN
            error := TRUE;
            status := errFull;
        END_IF;
    END_IF;
    
ELSIF requestOut THEN
    (* Storage Empty Check *)
    IF productNum <= 0 THEN
        error := TRUE;
        status := errEmpty;
    ELSE
        (* Search for occupied position from lowest to highest (1→9) *)
        i := 1;
        found := FALSE;
        WHILE i <= 9 AND NOT found DO
            IF library[i] THEN
                library[i] := FALSE;
                productNum := productNum - 1;
                libFreeNum := libFreeNum + 1;
                found := TRUE;
            END_IF;
            i := i + 1;
        END_WHILE;
        
        (* Verify search succeeded - safety fallback *)
        IF NOT found THEN
            error := TRUE;
            status := errEmpty;
        END_IF;
    END_IF;
END_IF;

(* Data consistency validation - ensure counters remain synchronized *)
IF libFreeNum + productNum <> 9 THEN
    (* Recovery logic: Recalculate based on actual array state *)
    productNum := 0;
    i := 1;
    WHILE i <= 9 DO
        IF library[i] THEN
            productNum := productNum + 1;
        END_IF;
        i := i + 1;
    END_WHILE;
    libFreeNum := 9 - productNum;
END_IF;

END_FUNCTION_BLOCK;