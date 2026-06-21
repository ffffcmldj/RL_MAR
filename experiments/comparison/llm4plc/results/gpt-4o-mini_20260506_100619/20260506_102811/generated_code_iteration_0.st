ructured-text
START_ST
FUNCTION_BLOCK FB_CourseDifferenceControl
VAR_INPUT
    KOMPASS_GRAD : INT; // Input compass angle
    KURS : INT; // Input course angle
END_VAR
VAR_OUTPUT
    KURS_DIFF : INT; // Output difference between course and compass
END_VAR

// Logic to compute the difference
IF KOMPASS_GRAD < 0 THEN
    KURS_DIFF := 0;
ELSE
    KURS_DIFF := KURS - KOMPASS_GRAD;

    // Adjust KURS_DIFF if it exceeds the defined boundaries
    IF KURS_DIFF > 1800 THEN
        KURS_DIFF := KURS_DIFF - 3600;
    ELSIF KURS_DIFF < -1800 THEN
        KURS_DIFF := KURS_DIFF + 3600;
    END_IF;
END_IF;

END_FUNCTION_BLOCK

PROGRAM MAIN
VAR
    fbCourseDiffControl : FB_CourseDifferenceControl; // Instance of the function block
    KOMPASS_GRAD : INT; // Compass angle input
    KURS : INT; // Course angle input
END_VAR

// Call the function block with the inputs
fbCourseDiffControl(KOMPASS_GRAD := KOMPASS_GRAD, KURS := KURS);

// Use the output
KURS_DIFF := fbCourseDiffControl.KURS_DIFF;

END_PROGRAM
END_ST