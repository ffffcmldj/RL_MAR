FUNCTION_BLOCK FB_ThresholdAccumulator
    VAR_INPUT
        i : INT; // Input integer value
    END_VAR

    VAR_OUTPUT
        o : INT; // Output integer value
    END_VAR

    VAR
        s1 : INT; // Internal variable for calculations
    END_VAR

    // Initialization of s1 at the start of each function block call
    s1 := 0;

    // Input Processing
    IF i > 0 THEN
        s1 := s1 + i; // Add input value to s1 if i is greater than 0
    END_IF;

    // Conditional Logic
    IF s1 = 42 THEN
        s1 := s1 + 8000; // Add 8000 to s1 if it equals 42
    END_IF;

    // Output Determination
    IF s1 < 0 THEN
        o := 0; // Set output to 0 if s1 is less than 0
    ELSE
        o := s1; // Set output to the current value of s1
    END_IF;

END_FUNCTION_BLOCK