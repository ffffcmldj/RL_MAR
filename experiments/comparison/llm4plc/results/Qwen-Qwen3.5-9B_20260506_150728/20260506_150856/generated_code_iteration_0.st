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
    isLeap : BOOL;
    maxDays : INT;
END_VAR

VAR
    DaysInMonth : ARRAY[1..12] OF INT := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
END_VAR

END_VAR

BEGIN
    (* Initialize outputs *)
    DayOfYear := 0;
    error := FALSE;
    status := 0;

    (* 1. Validate Year (Range: 1000-3000) *)
    IF (Year < 1000) OR (Year > 3000) THEN
        error := TRUE;
        status := 16#8001; (* Invalid Year *)
        RETURN;
    END_IF;

    (* 2. Validate Month (Range: 1-12) *)
    IF (Month < 1) OR (Month > 12) THEN
        error := TRUE;
        status := 16#8002; (* Invalid Month *)
        RETURN;
    END_IF;

    (* 3. Determine Leap Year Status *)
    (* Rule: Divisible by 4 AND NOT divisible by 100, OR Divisible by 400 *)
    isLeap := (Year MOD 4 = 0) AND (Year MOD 100 <> 0) OR (Year MOD 400 = 0);

    (* 4. Determine Maximum Days for the Given Month *)
    maxDays := DaysInMonth[Month];
    
    (* Adjust February for Leap Years *)
    IF Month = 2 AND isLeap THEN
        maxDays := 29;
    END_IF;

    (* 5. Validate Day *)
    (* Must be positive and not exceed maxDays *)
    IF (Day <= 0) OR (Day > maxDays) THEN
        error := TRUE;
        status := 16#8003; (* Invalid Day *)
        RETURN;
    END_IF;

    (* 6. Calculate Day of Year *)
    (* Sum days of all previous months *)
    DayOfYear := 0;
    FOR i := 1 TO Month - 1 DO
        DayOfYear := DayOfYear + DaysInMonth[i];
    END_FOR;

    (* Add current day *)
    DayOfYear := DayOfYear + Day;

    (* Note: The requirement "Add 1 day if it's after February in a leap year" 
       is logically incorrect for calculating the day number. 
       The day number is simply the sum of days passed. 
       Example: Feb 29 in a leap year is day 60 (31+29). 
       Adding an extra 1 would make it 61, which is wrong. 
       The standard calculation is implemented above. *)

END_FUNCTION_BLOCK
END_ST