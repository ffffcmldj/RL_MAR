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

(* Initialize the working variable with the input *)
x := x_in;

(* Process the input based on the defined rules *)
(* Rule 1 & 2: Add 1.0 if input is exactly 0.0 OR if input is not 0.0 *)
(* Since both conditions are mutually exclusive and cover all possibilities, this is an unconditional addition of 1.0 *)
x := x + 1.0;

(* Rule 3: Equality and inequality check - already satisfied by the unconditional addition above *)
(* No additional conditional logic required as the operation is already performed *)

(* Rule 4: Convert the original real input to an integer and, if the integer conversion is not zero, add 1.0 to the original real input *)
(* Note: The requirement specifies using the original real input (x_in) for this check *)
int_val := REAL_TO_INT(x_in);
IF int_val <> 0 THEN
    x := x + 1.0;
END_IF;

(* Assign the final result to the output *)
x_out := x;

END_FUNCTION_BLOCK