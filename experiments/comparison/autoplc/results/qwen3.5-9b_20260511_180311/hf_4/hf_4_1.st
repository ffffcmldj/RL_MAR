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
AccumulatedDays : INT;
MaxDays : INT;
IsLeap : BOOL;
END_VAR

VAR
DaysInMonth : ARRAY[1..12] OF INT := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
END_VAR

END_FUNCTION_BLOCK