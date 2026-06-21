ructured-text
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
    state : INT; // THE STATE VARIABLE
    prevState : INT; // THE PREVIOUS STATE VARIABLE
END_VAR

// STATE DEFINITIONS
CONST
    IDLE : INT := 0;
    SORTING_BIN1 : INT := 1;
    SORTING_BIN2 : INT := 2;
    SORTING_BIN3 : INT := 3;
END_CONST

// MAIN LOGIC
IF RFID1 THEN
    state := SORTING_BIN1;
ELSIF RFID2 THEN
    state := SORTING_BIN2;
ELSIF RFID3 THEN
    state := SORTING_BIN3;
ELSE
    state := IDLE;
END_IF;

// OUTPUT LOGIC BASED ON STATE
CASE state OF
    IDLE:
        Motor := FALSE;
        Bin1 := FALSE;
        Bin2 := FALSE;
        Bin3 := FALSE;
    SORTING_BIN1:
        Motor := TRUE;
        Bin1 := TRUE;
        Bin2 := FALSE;
        Bin3 := FALSE;
    SORTING_BIN2:
        Motor := TRUE;
        Bin1 := FALSE;
        Bin2 := TRUE;
        Bin3 := FALSE;
    SORTING_BIN3:
        Motor := TRUE;
        Bin1 := FALSE;
        Bin2 := FALSE;
        Bin3 := TRUE;
END_CASE;

END_FUNCTION_BLOCK
END_ST