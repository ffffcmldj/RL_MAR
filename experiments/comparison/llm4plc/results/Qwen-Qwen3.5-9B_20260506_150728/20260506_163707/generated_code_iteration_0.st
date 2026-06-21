START_ST
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
    currentState : INT;
END_VAR

// Initialize state to IDLE (0) on first execution or reset
IF currentState = 0 AND NOT RFID1 AND NOT RFID2 AND NOT RFID3 THEN
    currentState := 0;
ELSIF currentState = 0 AND RFID1 THEN
    currentState := 1;
ELSIF currentState = 0 AND RFID2 THEN
    currentState := 2;
ELSIF currentState = 0 AND RFID3 THEN
    currentState := 3;
ELSIF currentState = 1 AND RFID1 THEN
    currentState := 1;
ELSIF currentState = 1 AND (RFID2 OR RFID3) THEN
    IF RFID2 THEN
        currentState := 2;
    ELSIF RFID3 THEN
        currentState := 3;
    END_IF;
ELSIF currentState = 2 AND RFID2 THEN
    currentState := 2;
ELSIF currentState = 2 AND (RFID1 OR RFID3) THEN
    IF RFID1 THEN
        currentState := 1;
    ELSIF RFID3 THEN
        currentState := 3;
    END_IF;
ELSIF currentState = 3 AND RFID3 THEN
    currentState := 3;
ELSIF currentState = 3 AND (RFID1 OR RFID2) THEN
    IF RFID1 THEN
        currentState := 1;
    ELSIF RFID2 THEN
        currentState := 2;
    END_IF;
ELSIF (RFID1 = FALSE) AND (RFID2 = FALSE) AND (RFID3 = FALSE) THEN
    currentState := 0;
END_IF;

// Assign outputs based on current state
CASE currentState OF
    0: // IDLE
        Motor := FALSE;
        Bin1 := FALSE;
        Bin2 := FALSE;
        Bin3 := FALSE;
    1: // SORTING_BIN1
        Motor := TRUE;
        Bin1 := TRUE;
        Bin2 := FALSE;
        Bin3 := FALSE;
    2: // SORTING_BIN2
        Motor := TRUE;
        Bin1 := FALSE;
        Bin2 := TRUE;
        Bin3 := FALSE;
    3: // SORTING_BIN3
        Motor := TRUE;
        Bin1 := FALSE;
        Bin2 := FALSE;
        Bin3 := TRUE;
END_CASE
END_FUNCTION_BLOCK
END_ST