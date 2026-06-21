FUNCTION_BLOCK FB_CourseDifferenceControl
VAR_INPUT
    KOMPASS_GRAD : INT;
    KURS : INT;
END_VAR
VAR_OUTPUT
    KURS_DIFF : INT;
END_VAR
VAR
    raw_diff : INT;
END_VAR

// Step 1: Input validation
IF KOMPASS_GRAD < 0 THEN
    KURS_DIFF := 0;
    RETURN;
END_IF

// Step 2: Calculate raw difference
raw_diff := KURS - KOMPASS_GRAD;

// Step 3: Range correction for angular wrapping
IF raw_diff > 1800 THEN
    raw_diff := raw_diff - 3600;
ELSIF raw_diff < -1800 THEN
    raw_diff := raw_diff + 3600;
END_IF

// Step 4: Output assignment
KURS_DIFF := raw_diff;

END_FUNCTION_BLOCK