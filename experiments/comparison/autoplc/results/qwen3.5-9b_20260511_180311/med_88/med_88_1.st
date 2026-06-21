FUNCTION_BLOCK SmartLockerControl
VAR_INPUT
    AccessCode : INT;
    LockerNumber : INT;
END_VAR
VAR_OUTPUT
    LockerOpen : BOOL;
END_VAR
VAR
    LockerStatus : ARRAY[1..10] OF BOOL;
    LockerAccessCode : ARRAY[1..10] OF INT;
    i : INT;
    ValidNumber : BOOL;
    CodeMatch : BOOL;
END_VAR

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

FOR i := 1 TO 10 DO
    LockerStatus[i] := TRUE;
END_FOR

ValidNumber := (LockerNumber >= 1) AND (LockerNumber <= 10);

IF ValidNumber THEN
    CodeMatch := (AccessCode = LockerAccessCode[LockerNumber]);
    
    IF CodeMatch THEN
        LockerOpen := TRUE;
        LockerStatus[LockerNumber] := FALSE;
    ELSE
        LockerOpen := FALSE;
    END_IF
ELSE
    LockerOpen := FALSE;
END_IF

END_FUNCTION_BLOCK