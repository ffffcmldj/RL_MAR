FUNCTION_BLOCK SmartLockerControl
VAR_INPUT
    AccessCode : INT;     (* User entered access code *)
    LockerNumber : INT;   (* Selected locker number (1-10) *)
END_VAR
VAR_OUTPUT
    LockerOpen : BOOL;    (* TRUE when locker should open *)
END_VAR
VAR
    LockerStatus : ARRAY[1..10] OF BOOL := [TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE];
    LockerAccessCode : ARRAY[1..10] OF INT := [1234,5678,9876,4321,6543,7890,3456,8765,2345,6789];
    bInitialized : BOOL := FALSE;
END_VAR

(* One-time initialization *)
IF NOT bInitialized THEN
    bInitialized := TRUE;
END_IF;

(* Reset output at beginning of each cycle *)
LockerOpen := FALSE;

(* Access control logic *)
IF (LockerNumber >= 1) AND (LockerNumber <= 10) THEN
    IF AccessCode = LockerAccessCode[LockerNumber] THEN
        IF LockerStatus[LockerNumber] THEN
            LockerOpen := TRUE;
            LockerStatus[LockerNumber] := FALSE;
        END_IF;
    END_IF;
END_IF;

END_FUNCTION_BLOCK