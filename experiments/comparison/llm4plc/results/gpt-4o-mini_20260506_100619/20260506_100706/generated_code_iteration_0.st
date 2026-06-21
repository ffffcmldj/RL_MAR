ructured-text
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
    i: INT;
    isLeapYear: BOOL;
    state: INT; 
    prevState: INT; 
END_VAR

VAR
    DaysInMonth : ARRAY[1..12] OF INT := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]; 
END_VAR

// Initialize outputs
DayOfYear := 0;
error := FALSE;
status := 0;
state := 0;

// State machine
WHILE TRUE DO
    CASE state OF
        0: // INITIALIZE
            state := 1;

        1: // VALIDATE YEAR
            IF (Year < 1000) OR (Year > 3000) THEN
                status := 16#8001; // Invalid year
                error := TRUE;
                state := 6;
            ELSE
                state := 2; // Valid year
            END_IF;

        2: // VALIDATE MONTH
            IF (Month < 1) OR (Month > 12) THEN
                status := 16#8002; // Invalid month
                error := TRUE;
                state := 6;
            ELSE
                state := 3; // Valid month
            END_IF;

        3: // VALIDATE DAY
            IF Day <= 0 THEN
                status := 16#8003; // Invalid day
                error := TRUE;
                state := 6;
            ELSE
                state := 4; // Valid day
            END_IF;

        4: // CHECK LEAP YEAR
            isLeapYear := FALSE;
            IF (Year MOD 4 = 0 AND Year MOD 100 <> 0) OR (Year MOD 400 = 0) THEN
                isLeapYear := TRUE;
            END_IF;

            // Validate day for the month considering leap year
            IF (Month = 2 AND NOT isLeapYear AND Day > 28) OR 
               (Month = 2 AND isLeapYear AND Day > 29) OR 
               (Day > DaysInMonth[Month]) THEN
                status := 16#8003; // Invalid day
                error := TRUE;
                state := 6;
            ELSE
                state := 5; // Valid day
            END_IF;

        5: // CALCULATE DAY OF YEAR
            DayOfYear := 0;
            FOR i := 1 TO Month - 1 DO
                DayOfYear := DayOfYear + DaysInMonth[i];
            END_FOR;

            IF isLeapYear AND Month > 2 THEN
                DayOfYear := DayOfYear + 1; // Add an extra day for leap year
            END_IF;

            DayOfYear := DayOfYear + Day; // Add the current day
            state := 0; // Reset for next calculation

        6: // SET ERROR STATE
            // Error handling already set, reset state for next calculation
            state := 0; // Reset for next calculation

    END_CASE;
END_WHILE;

END_FUNCTION_BLOCK
END_ST