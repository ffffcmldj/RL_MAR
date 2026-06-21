START_ST
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
    isLeapYear : BOOL;
    maxDay : INT;
    tempDayOfYear : INT;
END_VAR

VAR
    DaysInMonth : ARRAY[1..12] OF INT := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
END_VAR

    (* Initialization *)
    DayOfYear := 0;
    error := FALSE;
    status := 0;
    isLeapYear := FALSE;
    maxDay := 0;
    tempDayOfYear := 0;

    (* Validate Month *)
    IF (Month < 1) OR (Month > 12) THEN
        error := TRUE;
        status := 16#8002;
        RETURN;
    END_IF;

    (* Validate Day - basic positivity *)
    IF Day <= 0 THEN
        error := TRUE;
        status := 16#8003;
        RETURN;
    END_IF;

    (* Determine leap year *)
    isLeapYear := ((Year MOD 4 = 0) AND (Year MOD 100 <> 0)) OR (Year MOD 400 = 0);

    (* Determine maxDay for the given month *)
    IF Month = 2 THEN
        IF isLeapYear THEN
            maxDay := 29;
        ELSE
            maxDay := 28;
        END_IF;
    ELSE
        maxDay := DaysInMonth[Month];
    END_IF;

    (* Validate Day - against maxDay *)
    IF Day > maxDay THEN
        error := TRUE;
        status := 16#8003;
        RETURN;
    END_IF;

    (* Validate Year *)
    IF (Year < 1000) OR (Year > 3000) THEN
        error := TRUE;
        status := 16#8001;
        RETURN;
    END_IF;

    (* Calculation - Sum days in completed months *)
    FOR i := 1 TO (Month - 1) DO
        tempDayOfYear := tempDayOfYear + DaysInMonth[i];
        (* Add extra day for February in a leap year *)
        IF (i = 2) AND isLeapYear THEN
            tempDayOfYear := tempDayOfYear + 1;
        END_IF;
    END_FOR;

    (* Add current day *)
    tempDayOfYear := tempDayOfYear + Day;

    (* Set final output *)
    DayOfYear := tempDayOfYear;

END_FUNCTION_BLOCK
END_ST