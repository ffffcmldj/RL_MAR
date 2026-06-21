(*
    FUNCTION_BLOCK: FB_CourseDifferenceControl
    PURPOSE: Computes the normalized angular difference between two integer inputs (in tenths of a degree).
    LOGIC:
        - If KOMPASS_GRAD < 0, KURS_DIFF is forced to 0 (error handling).
        - Otherwise, calculates KURS - KOMPASS_GRAD.
        - Normalizes the result to the range (-1800, 1800] by adding/subtracting 3600 as needed.
    VALIDATION:
        - Ensures output is always within [-1800, 1800] for valid inputs.
        - Handles negative compass input as a special error case.
*)

TYPE
    ST_CourseDifferenceData :
    STRUCT
        KOMPASS_GRAD : INT;
        KURS : INT;
        KURS_DIFF : INT;
        Status : INT; (* Use constants: INVALID_NEGATIVE, OVERFLOW_POSITIVE, OVERFLOW_NEGATIVE, VALID *)
    END_STRUCT;
END_TYPE

TYPE
    ARY_CourseDifferenceBuffer : ARRAY[0..9] OF ST_CourseDifferenceData;
END_TYPE

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

// Primary logic: Check for invalid compass input
IF KOMPASS_GRAD < 0 THEN
    KURS_DIFF := 0;
ELSE
    // Calculate raw difference
    iDiff := KURS - KOMPASS_GRAD;
    
    // Normalize the difference to the range (-1800, 1800]
    // Using IF statements is more efficient and deterministic than WHILE loops for this specific wrap.
    IF iDiff > 1800 THEN
        iDiff := iDiff - 3600;
    ELSIF iDiff <= -1800 THEN
        iDiff := iDiff + 3600;
    END_IF;
    
    KURS_DIFF := iDiff;
END_IF;

END_FUNCTION_BLOCK

(*
    MAIN PROGRAM: Example integration and data handling.
    NOTE: This program is provided for context and integration demonstration.
    The constants for the Status field (e.g., VALID) should be defined in a global configuration.
*)
PROGRAM MAIN
VAR
    fbCourseDiff : FB_CourseDifferenceControl;
    g_CourseDifferenceControlData : ST_CourseDifferenceData;
    g_CourseDifferenceBuffer : ARY_CourseDifferenceBuffer;
    nBufferIndex : INT := 0;
    // Example status constants (should be defined in a global constants list)
    INVALID_NEGATIVE : INT := 1;
    OVERFLOW_POSITIVE : INT := 2;
    OVERFLOW_NEGATIVE : INT := 3;
    VALID : INT := 0;
END_VAR

// Call the function block with data from the structure
fbCourseDiff(
    KOMPASS_GRAD := g_CourseDifferenceControlData.KOMPASS_GRAD,
    KURS := g_CourseDifferenceControlData.KURS
);
g_CourseDifferenceControlData.KURS_DIFF := fbCourseDiff.KURS_DIFF;

// Determine the status of the calculation based on inputs and result
IF g_CourseDifferenceControlData.KOMPASS_GRAD < 0 THEN
    g_CourseDifferenceControlData.Status := INVALID_NEGATIVE;
ELSIF fbCourseDiff.KURS_DIFF > 1800 THEN
    g_CourseDifferenceControlData.Status := OVERFLOW_POSITIVE;
ELSIF fbCourseDiff.KURS_DIFF < -1800 THEN
    g_CourseDifferenceControlData.Status := OVERFLOW_NEGATIVE;
ELSE
    g_CourseDifferenceControlData.Status := VALID;
END_IF;

// Buffer the result (cyclic buffer of size 10)
IF nBufferIndex >= 0 AND nBufferIndex < 10 THEN
    g_CourseDifferenceBuffer[nBufferIndex] := g_CourseDifferenceControlData;
    nBufferIndex := nBufferIndex + 1;
    IF nBufferIndex >= 10 THEN
        nBufferIndex := 0;
    END_IF;
END_IF;

END_PROGRAM