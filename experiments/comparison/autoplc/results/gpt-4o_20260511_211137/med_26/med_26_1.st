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
    // Internal variables can be declared here if needed
END_VAR

// Initialization: Ensure the system starts in the Idle State
Motor := FALSE;
Bin1 := FALSE;
Bin2 := FALSE;
Bin3 := FALSE;

// Detection and Activation Logic
IF RFID1 THEN
    // Activate motor and open Bin1
    Motor := TRUE;
    Bin1 := TRUE;
    Bin2 := FALSE;
    Bin3 := FALSE;
ELSIF RFID2 THEN
    // Activate motor and open Bin2
    Motor := TRUE;
    Bin1 := FALSE;
    Bin2 := TRUE;
    Bin3 := FALSE;
ELSIF RFID3 THEN
    // Activate motor and open Bin3
    Motor := TRUE;
    Bin1 := FALSE;
    Bin2 := FALSE;
    Bin3 := TRUE;
ELSE
    // Deactivation: No RFID detected, stop motor and close all bins
    Motor := FALSE;
    Bin1 := FALSE;
    Bin2 := FALSE;
    Bin3 := FALSE;
END_IF

END_FUNCTION_BLOCK