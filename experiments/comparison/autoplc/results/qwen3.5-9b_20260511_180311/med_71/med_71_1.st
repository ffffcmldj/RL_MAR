FUNCTION_BLOCK FB_Fibonacci_Calculator
VAR_INPUT
    N : DINT := 5;
END_VAR
VAR_OUTPUT
    O : DINT := 1;
END_VAR
VAR
    F1 : DINT := 1;
    F2 : DINT := 1;
    CNT : DINT := 2;
    NextVal : DINT;
    MaxLimit : DINT := 32767;
END_VAR

IF N <= 2 THEN
    O := 1;
ELSE
    F1 := 1;
    F2 := 1;
    CNT := 3;
    WHILE CNT <= N DO
        NextVal := F1 + F2;
        IF NextVal > MaxLimit THEN
            NextVal := MaxLimit;
        END_IF;
        F2 := F1;
        F1 := NextVal;
        CNT := CNT + 1;
    END_WHILE;
    O := F1;
END_IF;

END_FUNCTION_BLOCK