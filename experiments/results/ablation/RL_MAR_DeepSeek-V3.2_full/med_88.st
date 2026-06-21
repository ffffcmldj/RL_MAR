FUNCTION_BLOCK SmartLockerControl
VAR_INPUT
    AccessCode : INT; (* Input for user access code *)
    LockerNumber : INT; (* Input for selected locker number *)
END_VAR

VAR_OUTPUT
    LockerOpen : BOOL; (* Output to control locker door *)
END_VAR

VAR
    LockerStatus : ARRAY[1..10] OF BOOL; (* Status of individual lockers: TRUE=locked, FALSE=empty *)
    LockerAccessCode : ARRAY[1..10] OF INT; (* Locker access codes *)
    bInitDone : BOOL := FALSE; (* Initialization flag *)
    i : INT; (* Loop counter - declared but not used in final implementation *)
END_VAR

(* Initialization - runs only once *)
IF NOT bInitDone THEN
    (* Initialize access codes *)
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
    
    (* Initialize all lockers to locked state (TRUE = occupied/locked) *)
    FOR i := 1 TO 10 DO
        LockerStatus[i] := TRUE;
    END_FOR;
    
    bInitDone := TRUE;
END_IF;

(* Main access control logic *)
LockerOpen := FALSE; (* Reset output each scan cycle *)

IF (LockerNumber >= 1) AND (LockerNumber <= 10) THEN
    IF AccessCode = LockerAccessCode[LockerNumber] THEN
        LockerOpen := TRUE;
        LockerStatus[LockerNumber] := FALSE; (* Set locker to empty/unlocked *)
    END_IF;
END_IF;

END_FUNCTION_BLOCK;