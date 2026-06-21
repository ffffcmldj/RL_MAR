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

// Main logic
Motor := RFID1 OR RFID2 OR RFID3;

IF RFID1 THEN
    Bin1 := TRUE;
    Bin2 := FALSE;
    Bin3 := FALSE;
ELSIF RFID2 THEN
    Bin1 := FALSE;
    Bin2 := TRUE;
    Bin3 := FALSE;
ELSIF RFID3 THEN
    Bin1 := FALSE;
    Bin2 := FALSE;
    Bin3 := TRUE;
ELSE
    Bin1 := FALSE;
    Bin2 := FALSE;
    Bin3 := FALSE;
END_IF;

END_FUNCTION_BLOCK