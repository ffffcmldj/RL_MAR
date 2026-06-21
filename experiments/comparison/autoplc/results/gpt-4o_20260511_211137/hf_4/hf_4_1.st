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
        i: INT;
        LeapYear: BOOL;
        MaxDays: INT;
    END_VAR

    VAR
        DaysInMonth : ARRAY[1..12] OF INT := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    END_VAR

    // Initialization
    DayOfYear := 0;
    error := FALSE;
    status := 0;
    LeapYear := FALSE;

    // Input Validation
    // Month Validation
    IF (Month < 1) OR (Month > 12) THEN
        error := TRUE;
        status := 16#8002;
        RETURN;
    END_IF

    // Leap Year Determination
    IF ((Year MOD 4 = 0) AND (Year MOD 100 <> 0)) OR (Year MOD 400 = 0) THEN
        LeapYear := TRUE;
    END_IF

    // Day Validation
    IF Month = 2 THEN
        IF LeapYear THEN
            MaxDays := 29;
        ELSE
            MaxDays := 28;
        END_IF
    ELSE
        MaxDays := DaysInMonth[Month];
    END_IF

    IF (Day < 1) OR (Day > MaxDays) THEN
        error := TRUE;
        status := 16#8003;
        RETURN;
    END_IF

    // Year Validation
    IF (Year < 1000) OR (Year > 3000) THEN
        error := TRUE;
        status := 16#8001;
        RETURN;
    END_IF

    // Day of Year Calculation
    FOR i := 1 TO Month - 1 DO
        DayOfYear := DayOfYear + DaysInMonth[i];
    END_FOR

    DayOfYear := DayOfYear + Day;

    // Add extra day for leap year if after February
    IF LeapYear AND (Month > 2) THEN
        DayOfYear := DayOfYear + 1;
    END_IF

    // Successful completion
    error := FALSE;
    status := 0;

END_FUNCTION_BLOCK