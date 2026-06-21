plaintext
START_ST
FUNCTION_BLOCK FB_CourseDifferenceControl
VAR_INPUT
    KOMPASS_GRAD : INT; // Compass heading in tenths of a degree
    KURS         : INT; // Desired course in tenths of a degree
END_VAR
VAR_OUTPUT
    KURS_DIFF    : INT; // Computed course difference in tenths of a degree
END_VAR
VAR
    temp_diff    : INT; // Temporary variable for intermediate calculations
END_VAR

// Logic for course difference computation
IF KOMPASS_GRAD < 0 THEN
    KURS_DIFF := 0; // Set output to 0 if KOMPASS_GRAD is less than 0
ELSE
    temp_diff := KURS - KOMPASS_GRAD; // Calculate the initial difference
    IF temp_diff > 1800 THEN
        KURS_DIFF := temp_diff - 3600; // Adjust if the difference is greater than 1800
    ELSIF temp_diff < -1800 THEN
        KURS_DIFF := temp_diff + 3600; // Adjust if the difference is less than -1800
    ELSE
        KURS_DIFF := temp_diff; // No adjustment needed
    END_IF;
END_IF;

END_FUNCTION_BLOCK

PROGRAM MAIN
VAR
    fbCourseDifferenceControl : FB_CourseDifferenceControl; // Instance of the function block
    KOMPASS_GRAD_MAIN         : INT; // Compass heading input
    KURS_MAIN                 : INT; // Desired course input
    KURS_DIFF_MAIN            : INT; // Output course difference
END_VAR

// Initialize input variables
KOMPASS_GRAD_MAIN := 0; // Example initialization, can be replaced with actual values
KURS_MAIN := 0;         // Example initialization, can be replaced with actual values

// Call the function block
fbCourseDifferenceControl(KOMPASS_GRAD := KOMPASS_GRAD_MAIN, KURS := KURS_MAIN);

// Retrieve the output from the function block
KURS_DIFF_MAIN := fbCourseDifferenceControl.KURS_DIFF;

END_PROGRAM
END_ST