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
    // Temporary variables for control logic
    isBookDetected : BOOL;
END_VAR

// Initialization of outputs
Motor := FALSE;
Bin1 := FALSE;
Bin2 := FALSE;
Bin3 := FALSE;

// Check if any RFID reader detects a book
isBookDetected := RFID1 OR RFID2 OR RFID3;

// Control logic for motor and bins
IF isBookDetected THEN
    Motor := TRUE; // Activate motor when any RFID detects a book

    // Control bins based on which RFID detected a book
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
    END_IF;
ELSE
    // If no RFID detects a book, stop the motor and close all bins
    Motor := FALSE;
    Bin1 := FALSE;
    Bin2 := FALSE;
    Bin3 := FALSE;
END_IF;

END_FUNCTION_BLOCK