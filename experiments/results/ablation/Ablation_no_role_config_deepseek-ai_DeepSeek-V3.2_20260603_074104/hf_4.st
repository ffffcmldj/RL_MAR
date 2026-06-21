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
    idx : INT;
    isLeapYear : BOOL;
    maxDay : INT;
END_VAR

VAR
    DaysInMonth : ARRAY[1..12] OF INT := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
END_VAR

(* Initialize outputs *)
DayOfYear := 0;
error := FALSE;
status := 0;

(* 1. Month validation (highest priority) *)
IF (Month < 1) OR (Month > 12) THEN
    error := TRUE;
    status := 16#8002;  (* Invalid month *)
    RETURN;
END_IF;

(* 2. Day validation *)
(* First check if day is positive *)
IF Day <= 0 THEN
    error := TRUE;
    status := 16#8003;  (* Invalid day *)
    RETURN;
END_IF;

(* Determine maximum days for the month *)
maxDay := DaysInMonth[Month];

(* Check for February and leap year *)
IF Month = 2 THEN
    (* Leap year calculation *)
    isLeapYear := (((Year MOD 4) = 0) AND ((Year MOD 100) <> 0)) OR ((Year MOD 400) = 0);
    
    IF isLeapYear THEN
        maxDay := 29;
    ELSE
        maxDay := 28;
    END_IF;
END_IF;

(* Check if day exceeds maximum for the month *)
IF Day > maxDay THEN
    error := TRUE;
    status := 16#8003;  (* Invalid day *)
    RETURN;
END_IF;

(* 3. Year validation (lowest priority) *)
IF (Year < 1000) OR (Year > 3000) THEN
    error := TRUE;
    status := 16#8001;  (* Invalid year *)
    RETURN;
END_IF;

(* All inputs valid - calculate day of year *)
(* Sum days from completed months *)
FOR idx := 1 TO Month-1 DO
    DayOfYear := DayOfYear + DaysInMonth[idx];
    
    (* Add extra day for February in leap years *)
    IF (idx = 2) THEN
        (* Recalculate leap year for consistency *)
        isLeapYear := (((Year MOD 4) = 0) AND ((Year MOD 100) <> 0)) OR ((Year MOD 400) = 0);
        IF isLeapYear THEN
            DayOfYear := DayOfYear + 1;
        END_IF;
    END_IF;
END_FOR;

(* Add current day *)
DayOfYear := DayOfYear + Day;

END_FUNCTION_BLOCK