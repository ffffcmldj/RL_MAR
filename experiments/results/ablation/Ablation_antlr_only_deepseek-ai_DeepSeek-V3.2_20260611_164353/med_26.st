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
    (* Internal variable for consolidated detection logic *)
    bAnyRFIDDetected : BOOL;
END_VAR

(* Main Control Logic *)

(* Determine if any RFID reader is active *)
bAnyRFIDDetected := RFID1 OR RFID2 OR RFID3;

(* Control the conveyor motor *)
Motor := bAnyRFIDDetected;

(* Control sorting bins with explicit priority: RFID1 > RFID2 > RFID3 *)
Bin1 := RFID1;
Bin2 := RFID2 AND NOT RFID1;
Bin3 := RFID3 AND NOT RFID1 AND NOT RFID2;

END_FUNCTION_BLOCK