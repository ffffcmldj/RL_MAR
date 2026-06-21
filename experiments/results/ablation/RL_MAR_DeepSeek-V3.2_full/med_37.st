FUNCTION_BLOCK FB_RealValueAdjuster
VAR_INPUT
    x_in : REAL;
END_VAR

VAR_OUTPUT
    x_out : REAL;
END_VAR

VAR
    x : REAL;
END_VAR

x := x_in;

IF x_in = 0.0 THEN
    x := x + 1.0;
END_IF;

IF x_in <> 0.0 THEN
    x := x + 1.0;
END_IF;

IF REAL_TO_INT(x_in) <> 0 THEN
    x := x + 1.0;
END_IF;

x_out := x;
END_FUNCTION_BLOCK;