START_ST
FUNCTION_BLOCK SmartLockerControl
VAR_INPUT
    AccessCode : INT;
    LockerNumber : INT;
END_VAR
VAR_OUTPUT
    LockerOpen : BOOL;
END_VAR
VAR
    state : INT;
    prevState : INT;
    LockerStatus : ARRAY[1..10] OF BOOL;
    LockerAccessCode : ARRAY[1..10] OF INT;
    i : INT;
END_VAR

CASE state OF
    0: (* STATE 0: INITIALIZATION *)
        LockerOpen := FALSE;
        FOR i := 1 TO 10 DO
            LockerStatus[i] := TRUE;
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
        state := 1;

    1: (* STATE 1: IDLE *)
        LockerOpen := FALSE;
        IF (LockerNumber >= 1) AND (LockerNumber <= 10) AND (AccessCode = LockerAccessCode[LockerNumber]) THEN
            state := 2;
        ELSIF (LockerNumber < 1) OR (LockerNumber > 10) OR (AccessCode <> LockerAccessCode[LockerNumber]) THEN
            state := 3;
        END_IF;

    2: (* STATE 2: ACCESS_GRANTED *)
        LockerOpen := TRUE;
        LockerStatus[LockerNumber] := FALSE;
        state := 1;

    3: (* STATE 3: ACCESS_DENIED *)
        LockerOpen := FALSE;
        state := 1;

END_CASE;

prevState := state;
END_FUNCTION_BLOCK
END_ST