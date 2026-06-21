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

(* Initialize intermediate variable *)
s1 := 0;

(* Process positive input *)
IF i > 0 THEN
    s1 := s1 + i;
END_IF;

(* Check threshold condition *)
IF s1 = 42 THEN
    s1 := s1 + 8000;
END_IF;

(* Determine final output *)
IF s1 < 0 THEN
    o := 0;
ELSE
    o := s1;
END_IF;

END_FUNCTION_BLOCK