START_ST
FUNCTION_BLOCK FB_CourseDifferenceControl
VAR_INPUT
    KOMPASS_GRAD : INT;
    KURS : INT;
END_VAR
VAR_OUTPUT
    KURS_DIFF : INT;
END_VAR
VAR
    rawDiff : INT;
    correctedDiff : INT;
END_VAR

    IF KOMPASS_GRAD < 0 THEN
        KURS_DIFF := 0;
    ELSE
        rawDiff := KURS - KOMPASS_GRAD;
        IF rawDiff > 1800 THEN
            correctedDiff := rawDiff - 3600;
        ELSIF rawDiff < -1800 THEN
            correctedDiff := rawDiff + 3600;
        ELSE
            correctedDiff := rawDiff;
        END_IF;
        KURS_DIFF := correctedDiff;
    END_IF;

END_FUNCTION_BLOCK
END_ST