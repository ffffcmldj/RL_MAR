ructured-text
START_ST
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
    state : INT; (* Current state variable *)
    i : INT; (* Loop counter *)
END_VAR

(* Initialization Logic *)
IF state = 0 THEN
    FOR i := 1 TO 10 DO
        LockerStatus[i] := TRUE; (* Initialize all lockers to locked *)
    END_FOR;
    
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
    
    LockerOpen := FALSE; (* Initial state *)
    state := 1; (* Transition to WAIT FOR INPUT state *)
END_IF;

(* State 1: WAIT FOR INPUT *)
IF state = 1 THEN
    LockerOpen := FALSE; (* Waiting for input *)
    
    IF (LockerNumber >= 1) AND (LockerNumber <= 10) THEN
        state := 2; (* Transition to CHECK ACCESS CODE state *)
    END_IF;
END_IF;

(* State 2: CHECK ACCESS CODE *)
IF state = 2 THEN
    LockerOpen := FALSE; (* Checking access code *)
    
    IF AccessCode = LockerAccessCode[LockerNumber] THEN
        state := 3; (* Transition to OPEN LOCKER state *)
    END_IF;
END_IF;

(* State 3: OPEN LOCKER *)
IF state = 3 THEN
    LockerOpen := TRUE; (* Locker is opened *)
    state := 4; (* Transition to UPDATE LOCKER STATUS state *)
END_IF;

(* State 4: UPDATE LOCKER STATUS *)
IF state = 4 THEN
    LockerStatus[LockerNumber] := FALSE; (* Indicating locker is empty *)
    state := 1; (* Transition back to WAIT FOR INPUT state *)
END_IF;

END_FUNCTION_BLOCK
END_ST