FUNCTION_BLOCK SmartLockerControl
VAR_INPUT
    AccessCode : INT;     (* User entered access code *)
    LockerNumber : INT;   (* Selected locker number (1-10) *)
END_VAR
VAR_OUTPUT
    LockerOpen : BOOL;    (* TRUE when locker should open *)
END_VAR
VAR
    LockerStatus : ARRAY[1..10] OF BOOL;      (* TRUE=occupied/locked, FALSE=empty/unlocked *)
    LockerAccessCode : ARRAY[1..10] OF INT;   (* Unique access codes for each locker *)
    bInitDone : BOOL;                         (* Initialization flag *)
    i : INT;                                  (* Loop counter for initialization *)
END_VAR

(* Initialization - runs only once *)
IF NOT bInitDone THEN
    (* Initialize all lockers to occupied/locked (TRUE) *)
    FOR i := 1 TO 10 DO
        LockerStatus[i] := TRUE;
    END_FOR;
    
    (* Set individual access codes for each locker *)
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
    
    bInitDone := TRUE;
END_IF;

(* Default output state *)
LockerOpen := FALSE;

(* Access control logic *)
IF (LockerNumber >= 1) AND (LockerNumber <= 10) THEN
    (* Check if access code matches and locker is currently locked *)
    IF (AccessCode = LockerAccessCode[LockerNumber]) AND LockerStatus[LockerNumber] THEN
        LockerOpen := TRUE;               (* Open the locker *)
        LockerStatus[LockerNumber] := FALSE; (* Mark as empty/unlocked *)
    END_IF;
END_IF;
END_FUNCTION_BLOCK