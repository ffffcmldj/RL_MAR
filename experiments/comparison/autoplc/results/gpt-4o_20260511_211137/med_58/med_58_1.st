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

    // Function block code
    s1 := 0; // Initialize s1 to 0 at the start of each function block call

    // Check if the input value i is greater than 0
    IF i > 0 THEN
        s1 := s1 + i; // Add the value of i to s1
    END_IF

    // Check if s1 equals 42 after processing the input
    IF s1 = 42 THEN
        s1 := s1 + 8000; // Add 8000 to s1 if it equals 42
    END_IF

    // Determine the output value o based on the final value of s1
    IF s1 < 0 THEN
        o := 0; // Set the output o to 0 if s1 is less than 0
    ELSE
        o := s1; // Set the output o to the current value of s1 otherwise
    END_IF
END_FUNCTION_BLOCK