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

    // Initialize s1 to 0 at the start of each function block call
    s1 := 0;
    
    // If the input i is greater than 0, add its value to s1
    IF i > 0 THEN
        s1 := s1 + i;
    END_IF;
    
    // After the first condition, if s1 equals 42, add 8000 to s1
    IF s1 = 42 THEN
        s1 := s1 + 8000;
    END_IF;
    
    // For the final output:
    // If s1 is less than 0, set the output o to 0
    // Otherwise, set the output o to the current value of s1
    IF s1 < 0 THEN
        o := 0;
    ELSE
        o := s1;
    END_IF;
    
END_FUNCTION_BLOCK