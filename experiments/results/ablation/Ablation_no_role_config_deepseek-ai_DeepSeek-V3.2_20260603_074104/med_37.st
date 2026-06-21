FUNCTION_BLOCK FB_RealValueAdjuster
VAR_INPUT
    x_in : REAL;
END_VAR
VAR_OUTPUT
    x_out : REAL;
END_VAR
VAR
    x_temp : REAL;
    i_temp : INT;
END_VAR

x_temp := x_in;

(* First condition: check if input is exactly 0.0 *)
IF x_in = 0.0 THEN
    x_temp := x_temp + 1.0;
END_IF;

(* Second condition: check if input is not 0.0 *)
IF x_in <> 0.0 THEN
    x_temp := x_temp + 1.0;
END_IF;

(* Third condition: convert input to integer and check if not zero *)
i_temp := REAL_TO_INT(x_in);
IF i_temp <> 0 THEN
    x_temp := x_temp + 1.0;
END_IF;

x_out := x_temp;

END_FUNCTION_BLOCK