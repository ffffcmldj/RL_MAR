FUNCTION_BLOCK BookSorting
VAR_INPUT
    RFID1 : BOOL;
    RFID2 : BOOL;
    RFID3 : BOOL;
END_VAR
VAR_OUTPUT
    Motor : BOOL;
    Bin1 : BOOL;
    Bin2 : BOOL;
    Bin3 : BOOL;
END_VAR
VAR
    i : INT;
END_VAR
    Motor := FALSE;
    Bin1 := FALSE;
    Bin2 := FALSE;
    Bin3 := FALSE;
    IF RFID1 = TRUE THEN
        Motor := TRUE;
        Bin1 := TRUE;
    ELSIF RFID2 = TRUE THEN
        Motor := TRUE;
        Bin2 := TRUE;
    ELSIF RFID3 = TRUE THEN
        Motor := TRUE;
        Bin3 := TRUE;
    END_IF;
END_FUNCTION_BLOCK