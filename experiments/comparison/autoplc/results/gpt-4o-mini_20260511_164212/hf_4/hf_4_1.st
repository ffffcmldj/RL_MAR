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
    END_VAR

    VAR
        DaysInMonth : ARRAY[1..12] OF INT := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    END_VAR

    // Initialization
    DayOfYear := 0;
    error := FALSE;
    status := 0;

    // Input Validation Sequence
    // Month Validation
    IF (Month < 1) OR (Month > 12) THEN
        error := TRUE;
        status := 16#8002; // Invalid month
        RETURN;
    END_IF;

    // Day Validation
    IF Day <= 0 THEN
        error := TRUE;
        status := 16#8003; // Invalid day
        RETURN;
    END_IF;

    // Check maximum days for the given month
    IF Month = 2 THEN
        // Leap Year Calculation
        IF (Year MOD 4 = 0 AND Year MOD 100 <> 0) OR (Year MOD 400 = 0) THEN
            isLeapYear := TRUE;
        ELSE
            isLeapYear := FALSE;
        END_IF;

        IF isLeapYear THEN
            IF Day > 29 THEN
                error := TRUE;
                status := 16#8003; // Invalid day
                RETURN;
            END_IF;
        ELSE
            IF Day > 28 THEN
                error := TRUE;
                status := 16#8003; // Invalid day
                RETURN;
            END_IF;
        END_IF;
    ELSE
        IF Day > DaysInMonth[Month] THEN
            error := TRUE;
            status := 16#8003; // Invalid day
            RETURN;
        END_IF;
    END_IF;

    // Year Validation
    IF (Year < 1000) OR (Year > 3000) THEN
        error := TRUE;
        status := 16#8001; // Invalid year
        RETURN;
    END_IF;

    // Calculation Process
    // Sum the days in all completed months
    FOR i := 1 TO Month - 1 DO
        DayOfYear := DayOfYear + DaysInMonth[i];
    END_FOR;

    // Add the current day
    DayOfYear := DayOfYear + Day;

    // Add 1 day if it's after February in a leap year
    IF (Month > 2) AND isLeapYear THEN
        DayOfYear := DayOfYear + 1;
    END_IF;

END_FUNCTION_BLOCK