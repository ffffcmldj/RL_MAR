START_ST
FUNCTION_BLOCK FB_RealValueAdjuster
VAR_INPUT
    x_in : REAL;
END_VAR
VAR_OUTPUT
    x_out : REAL;
END_VAR
VAR
    x : REAL;
    int_val : INT;
END_VAR

    (* Initialize internal variable with input *)
    x := x_in;

    (* Rule 1: If input is exactly 0.0, add 1.0 *)
    IF x_in = 0.0 THEN
        x := x + 1.0;
    END_IF;

    (* Rule 2: If input is not 0.0, also add 1.0 *)
    IF x_in <> 0.0 THEN
        x := x + 1.0;
    END_IF;

    (* Additional explicit equality check: if equal to 0.0, add 1.0 *)
    IF x_in = 0.0 THEN
        x := x + 1.0;
    END_IF;

    (* Additional explicit inequality check: if not equal to 0.0, add 1.0 *)
    IF x_in <> 0.0 THEN
        x := x + 1.0;
    END_IF;

    (* Convert to integer with overflow safety check *)
    IF (x_in >= -32768.0) AND (x_in <= 32767.0) THEN
        int_val := REAL_TO_INT(x_in);
        (* If integer conversion is not zero, add 1.0 to the original real input *)
        IF int_val <> 0 THEN
            x := x + 1.0;
        END_IF;
    END_IF;

    (* Assign final result to output *)
    x_out := x;

END_FUNCTION_BLOCK
END_ST