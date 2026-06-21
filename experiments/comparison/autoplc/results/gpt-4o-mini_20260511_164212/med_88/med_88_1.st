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
        i : INT; (* Loop counter *)
    END_VAR

    (* Initialization of LockerStatus and LockerAccessCode *)
    FOR i := 1 TO 10 DO
        LockerStatus[i] := TRUE; (* Set all lockers to locked initially *)
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

    (* Access Control Logic *)
    IF (LockerNumber >= 1) AND (LockerNumber <= 10) THEN
        IF (AccessCode = LockerAccessCode[LockerNumber]) THEN
            LockerOpen := TRUE; (* Open the locker *)
            LockerStatus[LockerNumber] := FALSE; (* Mark locker as empty *)
        ELSE
            LockerOpen := FALSE; (* Access code does not match *)
        END_IF;
    ELSE
        LockerOpen := FALSE; (* Invalid locker number *)
    END_IF;

END_FUNCTION_BLOCK