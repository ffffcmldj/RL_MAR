FUNCTION_BLOCK FB_Sum
VAR_INPUT
    maxValue : INT;
END_VAR
VAR_OUTPUT
    wData : WORD;
END_VAR
VAR
    II : INT;
    tempSum : DINT;
END_VAR

tempSum := 0;
FOR II := 0 TO maxValue DO
    tempSum := tempSum + INT_TO_DINT(II);
END_FOR;
wData := DINT_TO_WORD(tempSum);
END_FUNCTION_BLOCK