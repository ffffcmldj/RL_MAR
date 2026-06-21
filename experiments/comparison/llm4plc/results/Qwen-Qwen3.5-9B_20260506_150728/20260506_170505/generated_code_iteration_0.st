START_ST
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

// STATE 0: INITIALIZE
// Reset s1 to 0 at the start of each function block call (every scan cycle)
s1 := 0;

// STATE 1: ACCUMULATE
// Check if input i is greater than 0, if true, add i to s1
IF i > 0 THEN
    s1 := s1 + i;
END_IF;

// STATE 2: THRESHOLD_CHECK
// After the first condition, check if s1 equals 42
// If true, add 8000 to s1
IF s1 = 42 THEN
    s1 := s1 + 8000;
END_IF;

// STATE 3: OUTPUT_CALCULATION
// Determine final output o based on s1
// If s1 is less than 0, set o to 0
// Otherwise, set o to the current value of s1
IF s1 < 0 THEN
    o := 0;
ELSE
    o := s1;
END_IF;

END_FUNCTION_BLOCK
END_ST