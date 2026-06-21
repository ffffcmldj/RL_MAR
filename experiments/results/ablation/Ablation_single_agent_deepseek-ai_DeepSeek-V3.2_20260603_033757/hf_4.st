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

VAR_TEMP
    i : INT;
    IsLeapYear : BOOL;
    MaxDayForMonth : INT;
END_VAR

VAR
    DaysInMonth : ARRAY[1..12] OF INT := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
END_VAR

(* Initialize outputs *)
DayOfYear := 0;
error := FALSE;
status := 0;

(* Validate Month - highest priority *)
IF (Month < 1) OR (Month > 12) THEN
    error := TRUE;
    status := 16#8002;
    RETURN;
END_IF;

(* Validate Year - lowest priority *)
IF (Year < 1000) OR (Year > 3000) THEN
    error := TRUE;
    status := 16#8001;
    RETURN;
END_IF;

(* Determine leap year *)
IsLeapYear := ((Year MOD 4) = 0) AND ((Year MOD 100) <> 0);
IsLeapYear := IsLeapYear OR ((Year MOD 400) = 0);

(* Determine maximum day for the given month *)
MaxDayForMonth := DaysInMonth[Month];
IF (Month = 2) AND IsLeapYear THEN
    MaxDayForMonth := 29;
END_IF;

(* Validate Day - second priority *)
IF (Day < 1) OR (Day > MaxDayForMonth) THEN
    error := TRUE;
    status := 16#8003;
    RETURN;
END_IF;

(* Calculate Day of Year *)
FOR i := 1 TO (Month - 1) DO
    DayOfYear := DayOfYear + DaysInMonth[i];
END_FOR;

DayOfYear := DayOfYear + Day;

(* Add extra day for leap year if month is after February *)
IF IsLeapYear AND (Month > 2) THEN
    DayOfYear := DayOfYear + 1;
END_IF;

END_FUNCTION_BLOCK