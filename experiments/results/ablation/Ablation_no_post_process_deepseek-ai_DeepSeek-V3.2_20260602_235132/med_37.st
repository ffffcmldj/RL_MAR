FUNCTION_BLOCK FB_RealValueAdjuster
VAR_INPUT
    x_in : REAL;
END_VAR

VAR_OUTPUT
    x_out : REAL;
END_VAR

VAR
    x_int : INT;
END_VAR

x_out := x_in;

IF x_in = 0.0 THEN
    x_out := x_out + 1.0;
END_IF;

IF x_in <> 0.0 THEN
    x_out := x_out + 1.0;
END_IF;

x_int := REAL_TO_INT(x_in);
IF x_int <> 0 THEN
    x_out := x_out + 1.0;
END_IF;

END_FUNCTION_BLOCK