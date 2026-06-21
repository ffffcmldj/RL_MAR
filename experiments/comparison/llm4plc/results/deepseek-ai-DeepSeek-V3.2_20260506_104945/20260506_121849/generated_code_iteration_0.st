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

    (* Step 1: Initialize s1 to 0 *)
    s1 := 0;

    (* Step 2: If input i is greater than 0, add its value to s1 *)
    IF i > 0 THEN
        s1 := s1 + i;
    END_IF;

    (* Step 3: After the first condition, if s1 equals 42, add 8000 to s1 *)
    IF s1 = 42 THEN
        s1 := s1 + 8000;
    END_IF;

    (* Step 4: Determine the final output o *)
    IF s1 < 0 THEN
        o := 0;
    ELSE
        o := s1;
    END_IF;

END_FUNCTION_BLOCK
END_ST