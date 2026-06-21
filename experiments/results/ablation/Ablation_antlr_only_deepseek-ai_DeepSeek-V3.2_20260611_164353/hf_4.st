TYPE
    E_Status : WORD
    (
        STATUS_OK := 0,
        STATUS_INVALID_YEAR := 16#8001,
        STATUS_INVALID_MONTH := 16#8002,
        STATUS_INVALID_DAY := 16#8003
    );
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
    status : E_Status;
END_VAR

VAR
    DaysInMonth : ARRAY[1..12] OF INT := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
END_VAR

VAR_TEMP
    i : INT;
    bIsLeapYear : BOOL;
    iMaxDayForMonth : INT;
END_VAR

    // Initialize outputs
    DayOfYear := 0;
    error := FALSE;
    status := STATUS_OK;

    // 1. Validate month (highest priority)
    IF (Month < 1) OR (Month > 12) THEN
        error := TRUE;
        status := STATUS_INVALID_MONTH;
        RETURN;
    END_IF;

    // 2. Determine leap year status (needed for day validation)
    // Leap year rule: divisible by 4 AND NOT divisible by 100, OR divisible by 400
    bIsLeapYear := ((Year MOD 4) = 0) AND ((Year MOD 100) <> 0) OR ((Year MOD 400) = 0);

    // 3. Validate day (depends on month and leap year status)
    // Get maximum days for the given month
    iMaxDayForMonth := DaysInMonth[Month];
    
    // Special handling for February in leap years
    IF (Month = 2) AND bIsLeapYear THEN
        iMaxDayForMonth := 29;
    END_IF;

    // Check day validity: must be positive and not exceed maximum for month
    IF (Day < 1) OR (Day > iMaxDayForMonth) THEN
        error := TRUE;
        status := STATUS_INVALID_DAY;
        RETURN;
    END_IF;

    // 4. Validate year (lowest priority)
    IF (Year < 1000) OR (Year > 3000) THEN
        error := TRUE;
        status := STATUS_INVALID_YEAR;
        RETURN;
    END_IF;

    // 5. Calculate day of year for valid inputs
    // Sum days from all completed months (months before current month)
    FOR i := 1 TO Month-1 DO
        DayOfYear := DayOfYear + DaysInMonth[i];
    END_FOR;

    // Add current day
    DayOfYear := DayOfYear + Day;

    // Add 1 for leap years if date is after February
    IF bIsLeapYear AND (Month > 2) THEN
        DayOfYear := DayOfYear + 1;
    END_IF;

END_FUNCTION_BLOCK