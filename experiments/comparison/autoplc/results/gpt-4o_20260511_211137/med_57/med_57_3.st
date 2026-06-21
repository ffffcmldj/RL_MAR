FUNCTION_BLOCK FB_CourseDifferenceControl
    VAR_INPUT
        KOMPASS_GRAD : INT;
        KURS : INT;
    END_VAR
    VAR_OUTPUT
        KURS_DIFF : INT;
    END_VAR

    VAR
        difference : INT;
    END_VAR

    // Input Validation
    IF KOMPASS_GRAD < 0 THEN
        KURS_DIFF := 0;
    ELSE
        // Difference Calculation
        difference := KURS - KOMPASS_GRAD;

        // Range Correction
        IF difference > 1800 THEN
            KURS_DIFF := difference - 3600;
        ELSIF difference < -1800 THEN
            KURS_DIFF := difference + 3600;
        ELSE
            KURS_DIFF := difference;
        END_IF
    END_IF
END_FUNCTION_BLOCK

PROGRAM MAIN
    VAR
        fbCourseDifferenceControl : FB_CourseDifferenceControl;
        komp_grad : INT := 0; // Example input for KOMPASS_GRAD
        kurs : INT := 0; // Example input for KURS
        kurs_diff : INT;
    END_VAR

    // Example usage of the function block
    fbCourseDifferenceControl.KOMPASS_GRAD := komp_grad;
    fbCourseDifferenceControl.KURS := kurs;
    fbCourseDifferenceControl(); // Correctly call the function block method
    kurs_diff := fbCourseDifferenceControl.KURS_DIFF;

    // Additional logic can be added here to use kurs_diff as needed
END_PROGRAM