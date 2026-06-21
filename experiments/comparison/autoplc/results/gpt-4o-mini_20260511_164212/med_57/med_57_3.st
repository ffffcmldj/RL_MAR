FUNCTION_BLOCK FB_CourseDifferenceControl
VAR_INPUT
    KOMPASS_GRAD : INT;
    KURS         : INT;
END_VAR

VAR_OUTPUT
    KURS_DIFF    : INT;
END_VAR

VAR
    TEMP_DIFF    : INT; // Temporary variable to hold the difference
END_VAR

// Initialization
KURS_DIFF := 0; // Default output value

// Input Validation
IF KOMPASS_GRAD < 0 THEN
    KURS_DIFF := 0; // Set output to 0 if KOMPASS_GRAD is less than 0
ELSE
    // Difference Calculation
    TEMP_DIFF := KURS - KOMPASS_GRAD; // Calculate the difference

    // Range Correction
    IF TEMP_DIFF > 1800 THEN
        TEMP_DIFF := TEMP_DIFF - 3600; // Correct if greater than 1800
    ELSIF TEMP_DIFF < -1800 THEN
        TEMP_DIFF := TEMP_DIFF + 3600; // Correct if less than -1800
    END_IF;

    // Output Assignment
    KURS_DIFF := TEMP_DIFF; // Assign the corrected difference to output
END_IF;

END_FUNCTION_BLOCK

PROGRAM MAIN
VAR
    courseControl : FB_CourseDifferenceControl; // Instance of the function block
    KOMPASS_GRAD  : INT := 1000; // Example input for KOMPASS_GRAD
    KURS          : INT := 2500; // Example input for KURS
END_VAR

// Properly invoke the function block in the cyclic execution context
courseControl(KOMPASS_GRAD := KOMPASS_GRAD, KURS := KURS); // Correct invocation

// The output can be accessed as follows
// KURS_DIFF will be available in courseControl.KURS_DIFF
END_PROGRAM