plaintext
START_ST

FUNCTION_BLOCK BookSorting
VAR_INPUT
    RFID1 : BOOL; // Input from RFID reader 1
    RFID2 : BOOL; // Input from RFID reader 2
    RFID3 : BOOL; // Input from RFID reader 3
END_VAR

VAR_OUTPUT
    Motor : BOOL; // Output to control the conveyor motor
    Bin1 : BOOL;  // Output to control Bin1
    Bin2 : BOOL;  // Output to control Bin2
    Bin3 : BOOL;  // Output to control Bin3
END_VAR

VAR
    state : INT; // The current state of the system
    prevState : INT; // The previous state of the system
END_VAR

// State Definitions
// STATE 0: IDLE - No RFID reader detects a book
// STATE 1: SORT_TO_BIN1 - RFID1 detects a book
// STATE 2: SORT_TO_BIN2 - RFID2 detects a book
// STATE 3: SORT_TO_BIN3 - RFID3 detects a book

// Initialization of variables
IF NOT (state >= 0 AND state <= 3) THEN
    state := 0; // Default to IDLE state
END_IF

// State Transition Logic
CASE state OF
    0: // IDLE
        IF RFID1 THEN
            state := 1; // Transition to SORT_TO_BIN1
        ELSIF RFID2 THEN
            state := 2; // Transition to SORT_TO_BIN2
        ELSIF RFID3 THEN
            state := 3; // Transition to SORT_TO_BIN3
        END_IF

    1: // SORT_TO_BIN1
        IF NOT RFID1 THEN
            state := 0; // Transition back to IDLE
        END_IF

    2: // SORT_TO_BIN2
        IF NOT RFID2 THEN
            state := 0; // Transition back to IDLE
        END_IF

    3: // SORT_TO_BIN3
        IF NOT RFID3 THEN
            state := 0; // Transition back to IDLE
        END_IF
END_CASE

// Output Logic
CASE state OF
    0: // IDLE
        Motor := FALSE;
        Bin1 := FALSE;
        Bin2 := FALSE;
        Bin3 := FALSE;

    1: // SORT_TO_BIN1
        Motor := TRUE;
        Bin1 := TRUE;
        Bin2 := FALSE;
        Bin3 := FALSE;

    2: // SORT_TO_BIN2
        Motor := TRUE;
        Bin1 := FALSE;
        Bin2 := TRUE;
        Bin3 := FALSE;

    3: // SORT_TO_BIN3
        Motor := TRUE;
        Bin1 := FALSE;
        Bin2 := FALSE;
        Bin3 := TRUE;
END_CASE

END_FUNCTION_BLOCK

END_ST