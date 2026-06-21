FUNCTION_BLOCK FB_RealValueAdjuster
VAR_INPUT
x_in : REAL;
END_VAR
VAR_OUTPUT
x_out : REAL;
END_VAR
VAR
x : REAL;
i_val : INT;
END_VAR

x := x_in;

IF x_in = 0.0 THEN
    x := x + 1.0;
END_IF;

IF x_in <> 0.0 THEN
    x := x + 1.0;
END_IF;

IF x_in >= -2147483648.0 AND x_in <= 2147483647.0 THEN
    i_val := INT(x_in);
    IF i_val <> 0 THEN
        x := x + 1.0;
    END_IF;
END_IF;

x_out := x;
END_FUNCTION_BLOCK