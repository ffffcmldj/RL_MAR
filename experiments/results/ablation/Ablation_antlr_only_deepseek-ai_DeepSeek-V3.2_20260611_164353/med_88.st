FUNCTION_BLOCK SmartLockerControl
VAR_INPUT
    AccessCode : INT;     (* User-provided access code *)
    LockerNumber : INT;   (* Selected locker number (1-10) *)
END_VAR

VAR_OUTPUT
    LockerOpen : BOOL;    (* TRUE when access is granted and locker should open *)
END_VAR

VAR
    LockerStatus : ARRAY[1..10] OF BOOL;      (* TRUE=occupied/locked, FALSE=empty/unlocked *)
    LockerAccessCode : ARRAY[1..10] OF INT;   (* Stored access codes for each locker *)
    bInitialized : BOOL := FALSE;             (* One-time initialization flag *)
END_VAR

(* One-time initialization of locker data *)
IF NOT bInitialized THEN
    (* Initialize all lockers to locked state (TRUE) *)
    LockerStatus[1] := TRUE;
    LockerStatus[2] := TRUE;
    LockerStatus[3] := TRUE;
    LockerStatus[4] := TRUE;
    LockerStatus[5] := TRUE;
    LockerStatus[6] := TRUE;
    LockerStatus[7] := TRUE;
    LockerStatus[8] := TRUE;
    LockerStatus[9] := TRUE;
    LockerStatus[10] := TRUE;
    
    (* Set predefined access codes *)
    LockerAccessCode[1] := 1234;
    LockerAccessCode[2] := 5678;
    LockerAccessCode[3] := 9876;
    LockerAccessCode[4] := 4321;
    LockerAccessCode[5] := 6543;
    LockerAccessCode[6] := 7890;
    LockerAccessCode[7] := 3456;
    LockerAccessCode[8] := 8765;
    LockerAccessCode[9] := 2345;
    LockerAccessCode[10] := 6789;
    
    bInitialized := TRUE;
END_IF;

(* Main access control logic *)
LockerOpen := FALSE;  (* Default state - locker remains closed *)

(* Validate locker number range *)
IF (LockerNumber >= 1) AND (LockerNumber <= 10) THEN
    (* Verify access code matches stored code for specified locker *)
    IF AccessCode = LockerAccessCode[LockerNumber] THEN
        (* Grant access and update locker status *)
        LockerOpen := TRUE;
        LockerStatus[LockerNumber] := FALSE;  (* Locker becomes empty/unlocked *)
    END_IF;
END_IF;

END_FUNCTION_BLOCK