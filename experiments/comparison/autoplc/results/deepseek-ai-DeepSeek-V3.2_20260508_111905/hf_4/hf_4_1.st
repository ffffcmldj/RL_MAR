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
    maxDays : INT;
    isLeapYear : BOOL;
    tempDayOfYear : INT;
END_VAR

VAR
    DaysInMonth : ARRAY[1..12] OF INT := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
END_VAR

    // Initialize outputs
    DayOfYear := 0;
    error := FALSE;
    status := 0;
    
    // 1. Month validation (highest priority)
    IF (Month < 1) OR (Month > 12) THEN
        error := TRUE;
        status := 16#8002;
        RETURN;
    END_IF;
    
    // 2. Day validation (second priority)
    // First check if day is positive
    IF Day <= 0 THEN
        error := TRUE;
        status := 16#8003;
        RETURN;
    END_IF;
    
    // Determine maximum days for the given month
    maxDays := DaysInMonth[Month];
    
    // Special handling for February
    IF Month = 2 THEN
        // Check if year is leap year (temporary check for day validation)
        // Leap year rule: divisible by 4 AND (not divisible by 100 OR divisible by 400)
        IF ((Year MOD 4 = 0) AND (Year MOD 100 <> 0)) OR (Year MOD 400 = 0) THEN
            maxDays := 29; // Leap year February
        ELSE
            maxDays := 28; // Non-leap year February
        END_IF;
    END_IF;
    
    // Check if day exceeds maximum for the month
    IF Day > maxDays THEN
        error := TRUE;
        status := 16#8003;
        RETURN;
    END_IF;
    
    // 3. Year validation (lowest priority)
    IF (Year < 1000) OR (Year > 3000) THEN
        error := TRUE;
        status := 16#8001;
        RETURN;
    END_IF;
    
    // All validations passed, calculate day of year
    
    // Determine if it's a leap year
    IF ((Year MOD 4 = 0) AND (Year MOD 100 <> 0)) OR (Year MOD 400 = 0) THEN
        isLeapYear := TRUE;
    ELSE
        isLeapYear := FALSE;
    END_IF;
    
    // Calculate day of year
    tempDayOfYear := 0;
    
    // Sum days from all months before current month
    FOR i := 1 TO Month-1 DO
        tempDayOfYear := tempDayOfYear + DaysInMonth[i];
        
        // Add extra day for February in leap years
        IF (i = 2) AND isLeapYear THEN
            tempDayOfYear := tempDayOfYear + 1;
        END_IF;
    END_FOR;
    
    // Add current day
    tempDayOfYear := tempDayOfYear + Day;
    
    // Assign final result
    DayOfYear := tempDayOfYear;
    
    // Set success status
    error := FALSE;
    status := 0;
    
END_FUNCTION_BLOCK