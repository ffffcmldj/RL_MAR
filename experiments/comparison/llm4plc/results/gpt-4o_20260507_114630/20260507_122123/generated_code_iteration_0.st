plaintext
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
    state : INT; (* State variable for FSM *)
    i : INT; (* Loop counter for initialization *)
END_VAR

(* Initialization logic *)
IF state = 0 THEN
    (* Initialize LockerAccessCode array *)
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

    (* Initialize LockerStatus array to TRUE (locked) *)
    FOR i := 1 TO 10 DO
        LockerStatus[i] := TRUE;
    END_FOR;

    (* Set initial state to VALIDATE LOCKER NUMBER *)
    state := 1;
    LockerOpen := FALSE; (* Ensure locker is closed initially *)
END_IF

(* State 1: Validate Locker Number *)
IF state = 1 THEN
    LockerOpen := FALSE; (* Ensure locker remains closed during validation *)

    IF (LockerNumber >= 1) AND (LockerNumber <= 10) THEN
        (* Locker number is valid, proceed to validate access code *)
        state := 2;
    ELSE
        (* Locker number is invalid, transition to error handling *)
        state := 4;
    END_IF
END_IF

(* State 2: Validate Access Code *)
IF state = 2 THEN
    LockerOpen := FALSE; (* Ensure locker remains closed during validation *)

    IF (AccessCode = LockerAccessCode[LockerNumber]) AND (LockerStatus[LockerNumber] = TRUE) THEN
        (* Access code matches and locker is locked, proceed to open locker *)
        state := 3;
    ELSE
        (* Access code is invalid or locker is already empty, transition to error handling *)
        state := 4;
    END_IF
END_IF

(* State 3: Open Locker *)
IF state = 3 THEN
    LockerOpen := TRUE; (* Open the locker *)
    LockerStatus[LockerNumber] := FALSE; (* Update locker status to empty *)

    (* Transition back to validate locker number for the next operation *)
    state := 1;
END_IF

(* State 4: Error Handling *)
IF state = 4 THEN
    LockerOpen := FALSE; (* Ensure locker remains closed *)
    (* Handle invalid inputs or access attempts (e.g., log error, reset outputs) *)

    (* Transition back to validate locker number for the next operation *)
    state := 1;
END_IF
END_FUNCTION_BLOCK
END_ST