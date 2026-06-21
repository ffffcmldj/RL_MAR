FUNCTION_BLOCK FB_CourseDifferenceControl
VAR_INPUT
    KOMPASS_GRAD : INT;
    KURS : INT;
END_VAR
VAR_OUTPUT
    KURS_DIFF : INT;
END_VAR
VAR
    iDiff : INT;
END_VAR

IF KOMPASS_GRAD < 0 THEN
    KURS_DIFF := 0;
ELSE
    iDiff := KURS - KOMPASS_GRAD;
    
    (* Normalize the angular difference to the range [-1800, 1800] *)
    IF iDiff > 1800 THEN
        iDiff := iDiff - 3600;
    ELSIF iDiff < -1800 THEN
        iDiff := iDiff + 3600;
    END_IF;
    
    KURS_DIFF := iDiff;
END_IF;

END_FUNCTION_BLOCK