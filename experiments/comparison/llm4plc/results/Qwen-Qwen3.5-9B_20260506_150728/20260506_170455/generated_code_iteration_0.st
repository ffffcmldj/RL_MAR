START_ST
FUNCTION_BLOCK FB_CourseDifferenceControl
VAR_INPUT
    KOMPASS_GRAD : INT;
    KURS         : INT;
END_VAR
VAR_OUTPUT
    KURS_DIFF    : INT;
END_VAR
VAR
    raw_diff     : INT; // Intermediate variable to store KURS - KOMPASS_GRAD
END_VAR

// STATE 0: INITIALIZE
// Since this is a pure function block without memory retention for state,
// execution begins immediately at STATE 1 logic.

// STATE 1: INPUT VALIDATION
// Check if KOMPASS_GRAD is less than 0.
// If true, the output should be 0.
IF KOMPASS_GRAD < 0 THEN
    KURS_DIFF := 0;
    // Logic ends here for this scan cycle; transition to STATE 4 effectively
    RETURN;
END_IF

// STATE 2: DIFFERENCE CALCULATION
// Calculate the raw difference between KURS and KOMPASS_GRAD.
raw_diff := KURS - KOMPASS_GRAD;

// STATE 3: RANGE CORRECTION
// Apply wrapping logic to ensure the result is within the -1800 to +1800 range.
// If the difference is greater than 1800, subtract 3600.
IF raw_diff > 1800 THEN
    raw_diff := raw_diff - 3600;
ELSIF raw_diff < -1800 THEN
    // If the difference is less than -1800, add 3600.
    raw_diff := raw_diff + 3600;
END_IF

// STATE 4: OUTPUT ASSIGNMENT
// Assign the final corrected value to the output variable.
KURS_DIFF := raw_diff;

END_FUNCTION_BLOCK
END_ST