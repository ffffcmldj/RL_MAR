FUNCTION_BLOCK FB_SimpleRepeat
VAR_INPUT
    INPUT_VAR1 : INT := 2;
    INPUT_COUNTER : INT := 4;
END_VAR

VAR_OUTPUT
    OUTPUT_VAR1 : INT;
END_VAR

VAR
    COUNTER : INT;
END_VAR

(* Initialize output with input value *)
OUTPUT_VAR1 := INPUT_VAR1;

(* Use local counter to preserve original input parameter *)
COUNTER := INPUT_COUNTER;

(* Execute multiplication loop at least once *)
REPEAT
    OUTPUT_VAR1 := OUTPUT_VAR1 * 2;
    COUNTER := COUNTER - 1;
UNTIL COUNTER <= 0
END_REPEAT;

END_FUNCTION_BLOCK