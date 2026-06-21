TYPE
    E_STATUS : (STATUS_OK := 0, STATUS_INVALID_YEAR := 16#8001, STATUS_INVALID_MONTH := 16#8002, STATUS_INVALID_DAY := 16#8003);
END_TYPE

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
END_VAR

VAR_TEMP
    i : INT;
    LeapYear : BOOL;
    MaxDay : INT;
END_VAR

    // Initialize outputs
    DayOfYear := 0;
    error := FALSE;
    status := WORD(STATUS_OK);

    // 1. Validate Month (highest priority)
    IF (Month < 1) OR (Month > 12) THEN
        error := TRUE;
        status := WORD(STATUS_INVALID_MONTH);
        RETURN;
    END_IF;

    // 2. Validate Day (second priority)
    // Check for positive value
    IF (Day <= 0) THEN
        error := TRUE;
        status := WORD(STATUS_INVALID_DAY);
        RETURN;
    END_IF;

    // Determine maximum days for the given month
    MaxDay := DaysInMonth[Month];
    IF (Month = 2) THEN
        // Calculate leap year for February validation
        LeapYear := ((Year MOD 4 = 0) AND (Year MOD 100 <> 0)) OR (Year MOD 400 = 0);
        IF LeapYear THEN
            MaxDay := 29;
        END_IF;
    END_IF;

    // Check if day exceeds maximum for the month
    IF (Day > MaxDay) THEN
        error := TRUE;
        status := WORD(STATUS_INVALID_DAY);
        RETURN;
    END_IF;

    // 3. Validate Year (lowest priority)
    IF (Year < 1000) OR (Year > 3000) THEN
        error := TRUE;
        status := WORD(STATUS_INVALID_YEAR);
        RETURN;
    END_IF;

    // All inputs are valid - proceed with calculation
    // Recalculate leap year for the final calculation
    LeapYear := ((Year MOD 4 = 0) AND (Year MOD 100 <> 0)) OR (Year MOD 400 = 0);
    
    // Start with the current day
    DayOfYear := Day;
    
    // Add days from all completed months
    FOR i := 1 TO (Month - 1) DO
        DayOfYear := DayOfYear + DaysInMonth[i];
    END_FOR;
    
    // Add extra day for leap year if date is after February
    IF (LeapYear AND (Month > 2)) THEN
        DayOfYear := DayOfYear + 1;
    END_IF;

END_FUNCTION_BLOCK