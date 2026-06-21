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

// First condition: if exactly 0.0, add 1.0
IF x_temp = 0.0 THEN
    x_temp := x_temp + 1.0;
END_IF;

// Second condition: if not 0.0, also add 1.0
IF x_temp <> 0.0 THEN
    x_temp := x_temp + 1.0;
END_IF;

// Convert to integer and check
i_temp := REAL_TO_INT(x_temp);
IF i_temp <> 0 THEN
    x_temp := x_temp + 1.0;
END_IF;

x_out := x_temp;

END_FUNCTION_BLOCK