FUNCTION_BLOCK SmartLockerControl
VAR_INPUT
    AccessCode : INT;      (* User entered access code *)
    LockerNumber : INT;    (* Selected locker number (1-10) *)
END_VAR
VAR_OUTPUT
    LockerOpen : BOOL;     (* TRUE when locker should open *)
END_VAR
VAR
    LockerStatus : ARRAY[1..10] OF BOOL;       (* TRUE=locked/occupied, FALSE=empty *)
    LockerAccessCode : ARRAY[1..10] OF INT;    (* Stored access codes *)
    bInitialized : BOOL := FALSE;              (* Initialization flag *)
END_VAR

(* Initialization - runs once on first execution *)
IF NOT bInitialized THEN
    (* Initialize all lockers to TRUE (locked) *)
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
LockerOpen := FALSE;  (* Default output state *)

(* Validate locker number range *)
IF (LockerNumber >= 1) AND (LockerNumber <= 10) THEN
    (* Check if access code matches and locker is currently locked *)
    IF (AccessCode = LockerAccessCode[LockerNumber]) AND LockerStatus[LockerNumber] THEN
        LockerOpen := TRUE;                    (* Signal to open the locker *)
        LockerStatus[LockerNumber] := FALSE;   (* Mark locker as empty/unlocked *)
    END_IF;
END_IF;

END_FUNCTION_BLOCK