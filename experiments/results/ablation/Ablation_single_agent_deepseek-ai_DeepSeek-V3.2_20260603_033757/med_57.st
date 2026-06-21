FUNCTION_BLOCK FB_CourseDifferenceControl
VAR_INPUT
    KOMPASS_GRAD : INT;
    KURS : INT;
END_VAR
VAR_OUTPUT
    KURS_DIFF : INT;
END_VAR
VAR
    tempDiff : INT;
END_VAR

// Main logic
IF KOMPASS_GRAD < 0 THEN
    KURS_DIFF := 0;
ELSE
    tempDiff := KURS - KOMPASS_GRAD;
    
    // Handle angle wrapping (3600 = 360 degrees * 10 for decimal precision)
    IF tempDiff > 1800 THEN
        tempDiff := tempDiff - 3600;
    ELSIF tempDiff < -1800 THEN
        tempDiff := tempDiff + 3600;
    END_IF;
    
    KURS_DIFF := tempDiff;
END_IF;
END_FUNCTION_BLOCK

PROGRAM MAIN
VAR
    courseControl : FB_CourseDifferenceControl;
    testKOMPASS : INT;
    testKURS : INT;
    resultDiff : INT;
END_VAR

// Example usage of the function block
courseControl(KOMPASS_GRAD := testKOMPASS, KURS := testKURS);
resultDiff := courseControl.KURS_DIFF;
END_PROGRAM