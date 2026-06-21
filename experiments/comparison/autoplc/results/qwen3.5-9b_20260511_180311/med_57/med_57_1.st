FUNCTION_BLOCK FB_CourseDifferenceControl
VAR_INPUT
    KOMPASS_GRAD : INT;
    KURS         : INT;
END_VAR
VAR_OUTPUT
    KURS_DIFF    : INT;
END_VAR
VAR
    Raw_Diff     : INT;
END_VAR

IF KOMPASS_GRAD < 0 THEN
    KURS_DIFF := 0;
ELSE
    Raw_Diff := KURS - KOMPASS_GRAD;
    IF Raw_Diff > 1800 THEN
        Raw_Diff := Raw_Diff - 3600;
    END_IF;
    IF Raw_Diff < -1800 THEN
        Raw_Diff := Raw_Diff + 3600;
    END_IF;
    KURS_DIFF := Raw_Diff;
END_IF;

END_FUNCTION_BLOCK