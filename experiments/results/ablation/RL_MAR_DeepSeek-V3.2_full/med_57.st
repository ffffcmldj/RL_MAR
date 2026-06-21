FUNCTION_BLOCK FB_CourseDifferenceControl
VAR_INPUT
    KOMPASS_GRAD : INT;
    KURS : INT;
END_VAR

VAR_OUTPUT
    KURS_DIFF : INT;
END_VAR

VAR
    iTempDiff : INT;
END_VAR

IF KOMPASS_GRAD < 0 THEN
    KURS_DIFF := 0;
ELSE
    iTempDiff := KURS - KOMPASS_GRAD;
    
    IF iTempDiff > 1800 THEN
        iTempDiff := iTempDiff - 3600;
    ELSIF iTempDiff < -1800 THEN
        iTempDiff := iTempDiff + 3600;
    END_IF;
    
    KURS_DIFF := iTempDiff;
END_IF;

END_FUNCTION_BLOCK