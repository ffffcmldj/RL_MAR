FUNCTION_BLOCK FB_CalculateDayOfYear
VAR_INPUT
    Year : INT;
    Month : INT;
    Day : INT;
END_VAR

VAR_OUTPUT
    DayOfYear : INT;
    error : BOOL;
    status : WORD;
END_VAR

VAR
    DaysInMonth : ARRAY[1..12] OF INT := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    i : INT;
    IsLeap : BOOL;
    MaxDay : INT;
END_VAR

DayOfYear := 0;
error := FALSE;
status := 0;

IF (Month < 1) OR (Month > 12) THEN
    error := TRUE;
    status := 16#8002;
    RETURN;
END_IF;

IsLeap := ((Year MOD 4) = 0) AND ((Year MOD 100) <> 0) OR ((Year MOD 400) = 0);
MaxDay := DaysInMonth[Month];

IF Month = 2 THEN
    IF IsLeap THEN
        MaxDay := 29;
    ELSE
        MaxDay := 28;
    END_IF;
END_IF;

IF (Day < 1) OR (Day > MaxDay) THEN
    error := TRUE;
    status := 16#8003;
    RETURN;
END_IF;

IF (Year < 1000) OR (Year > 3000) THEN
    error := TRUE;
    status := 16#8001;
    RETURN;
END_IF;

FOR i := 1 TO Month-1 DO
    DayOfYear := DayOfYear + DaysInMonth[i];
END_FOR;

DayOfYear := DayOfYear + Day;

IF IsLeap AND (Month > 2) THEN
    DayOfYear := DayOfYear + 1;
END_IF;

END_FUNCTION_BLOCK;