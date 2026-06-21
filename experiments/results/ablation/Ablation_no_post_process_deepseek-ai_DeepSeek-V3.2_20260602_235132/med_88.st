TYPE
    LockerStatusType : ARRAY[1..10] OF BOOL;
    LockerAccessCodeType : ARRAY[1..10] OF INT;
END_TYPE

FUNCTION_BLOCK SmartLockerControl
VAR_INPUT
    AccessCode : INT;     (* User entered access code *)
    LockerNumber : INT;   (* Selected locker number (1-10) *)
END_VAR
VAR_OUTPUT
    LockerOpen : BOOL;    (* TRUE when locker should open *)
END_VAR
VAR
    LockerStatus : LockerStatusType := [TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE];
    LockerAccessCode : LockerAccessCodeType := [1234, 5678, 9876, 4321, 6543, 7890, 3456, 8765, 2345, 6789];
    validLockerNumber : BOOL;
    codeMatches : BOOL;
END_VAR

(* Validate locker number is within range *)
validLockerNumber := (LockerNumber >= 1) AND (LockerNumber <= 10);

(* Check if access code matches for the specified locker *)
IF validLockerNumber THEN
    codeMatches := (AccessCode = LockerAccessCode[LockerNumber]);
ELSE
    codeMatches := FALSE;
END_IF;

(* Main access control logic *)
IF validLockerNumber AND codeMatches AND LockerStatus[LockerNumber] THEN
    LockerOpen := TRUE;
    LockerStatus[LockerNumber] := FALSE;  (* Mark locker as empty after opening *)
ELSE
    LockerOpen := FALSE;
END_IF;

END_FUNCTION_BLOCK;