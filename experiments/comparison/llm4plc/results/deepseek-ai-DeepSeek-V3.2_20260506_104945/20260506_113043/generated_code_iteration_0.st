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
    state : INT := 0;
    prevState : INT := 0;
END_VAR

(* State Machine Execution *)
prevState := state;

CASE state OF
    0: (* IDLE *)
        Motor := FALSE;
        Bin1 := FALSE;
        Bin2 := FALSE;
        Bin3 := FALSE;
        
        IF RFID1 THEN
            state := 1;
        ELSIF RFID2 THEN
            state := 2;
        ELSIF RFID3 THEN
            state := 3;
        ELSE
            state := 0;
        END_IF;
        
    1: (* SORT_TO_BIN1 *)
        Motor := TRUE;
        Bin1 := TRUE;
        Bin2 := FALSE;
        Bin3 := FALSE;
        
        IF RFID1 THEN
            state := 1;
        ELSIF RFID2 THEN
            state := 2;
        ELSIF RFID3 THEN
            state := 3;
        ELSE
            state := 0;
        END_IF;
        
    2: (* SORT_TO_BIN2 *)
        Motor := TRUE;
        Bin1 := FALSE;
        Bin2 := TRUE;
        Bin3 := FALSE;
        
        IF RFID2 THEN
            state := 2;
        ELSIF RFID1 THEN
            state := 1;
        ELSIF RFID3 THEN
            state := 3;
        ELSE
            state := 0;
        END_IF;
        
    3: (* SORT_TO_BIN3 *)
        Motor := TRUE;
        Bin1 := FALSE;
        Bin2 := FALSE;
        Bin3 := TRUE;
        
        IF RFID3 THEN
            state := 3;
        ELSIF RFID1 THEN
            state := 1;
        ELSIF RFID2 THEN
            state := 2;
        ELSE
            state := 0;
        END_IF;
        
    ELSE
        state := 0;
        Motor := FALSE;
        Bin1 := FALSE;
        Bin2 := FALSE;
        Bin3 := FALSE;
END_CASE;

END_FUNCTION_BLOCK
END_ST