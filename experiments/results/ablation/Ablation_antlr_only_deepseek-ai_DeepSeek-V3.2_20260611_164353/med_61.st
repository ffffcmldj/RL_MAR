FUNCTION_BLOCK FB_Sum
VAR_INPUT
    maxValue : INT;
END_VAR
VAR_OUTPUT
    wData : WORD;
END_VAR
VAR
    II : INT;
END_VAR

(* Initialize output *)
wData := 0;

(* Sum integers from 0 to maxValue *)
FOR II := 0 TO maxValue DO
    wData := wData + WORD(II);
END_FOR;

END_FUNCTION_BLOCK;