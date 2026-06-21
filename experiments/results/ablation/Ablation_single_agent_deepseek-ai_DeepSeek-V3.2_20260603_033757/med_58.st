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
s1 := 0; // Initialize s1 at start of each call

IF i > 0 THEN
    s1 := s1 + i; // Add i to s1 if i > 0
END_IF;

IF s1 = 42 THEN
    s1 := s1 + 8000; // Add 8000 if s1 equals 42
END_IF;

// Determine output value
IF s1 < 0 THEN
    o := 0;
ELSE
    o := s1;
END_IF;

END_FUNCTION_BLOCK