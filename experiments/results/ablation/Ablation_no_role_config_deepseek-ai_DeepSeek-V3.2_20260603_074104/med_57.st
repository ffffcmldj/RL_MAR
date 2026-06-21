FUNCTION_BLOCK FB_CourseDifferenceControl
VAR_INPUT
    KOMPASS_GRAD : INT;
    KURS : INT;
END_VAR
VAR_OUTPUT
    KURS_DIFF : INT;
END_VAR
VAR
    diff_temp : INT;
END_VAR

// Main logic
IF KOMPASS_GRAD < 0 THEN
    KURS_DIFF := 0;
ELSE
    diff_temp := KURS - KOMPASS_GRAD;
    
    // Apply range correction for angles
    IF diff_temp > 1800 THEN
        diff_temp := diff_temp - 3600;
    ELSIF diff_temp < -1800 THEN
        diff_temp := diff_temp + 3600;
    END_IF;
    
    KURS_DIFF := diff_temp;
END_IF;
END_FUNCTION_BLOCK

PROGRAM MAIN
VAR
    fbCourseDiff : FB_CourseDifferenceControl;
    kompass_grad_input : INT;
    kurs_input : INT;
    kurs_diff_output : INT;
END_VAR

// Call the function block
fbCourseDiff(KOMPASS_GRAD := kompass_grad_input, KURS := kurs_input);
kurs_diff_output := fbCourseDiff.KURS_DIFF;
END_PROGRAM