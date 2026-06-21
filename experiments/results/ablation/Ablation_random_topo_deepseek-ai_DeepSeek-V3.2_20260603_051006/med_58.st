FUNCTION_BLOCK FB_ThresholdAccumulator
VAR_INPUT
    i : INT;
END_VAR

VAR_OUTPUT
    o : INT;
END_VAR

VAR
    s1 : INT;
END_VAR

// Main logic
s1 := 0; // Initialize s1 to 0 at the start of each call

// Process positive input values
IF i > 0 THEN
    s1 := s1 + i;
END_IF;

// Check threshold condition
IF s1 = 42 THEN
    s1 := s1 + 8000;
END_IF;

// Determine final output
IF s1 < 0 THEN
    o := 0;
ELSE
    o := s1;
END_IF;

END_FUNCTION_BLOCK