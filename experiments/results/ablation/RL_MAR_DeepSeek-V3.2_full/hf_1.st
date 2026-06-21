FUNCTION_BLOCK StackMin
VAR_INPUT
    push : BOOL;
    pop : BOOL;
    reset : BOOL;
END_VAR

VAR_OUTPUT
    error : BOOL;
    status : WORD;
END_VAR

VAR_IN_OUT
    item : INT;
    stack : ARRAY[0..3] OF INT;
END_VAR

VAR
    top : INT := -1;
    i : INT;
    j : INT;
    minIndex : INT;
    minValue : INT;
END_VAR

IF reset THEN
    top := -1;
    error := FALSE;
    status := 16#0000;
ELSIF push THEN
    IF top >= 3 THEN
        error := TRUE;
        status := 16#8A04;
    ELSE
        top := top + 1;
        stack[top] := item;
        error := FALSE;
        status := 16#0000;
    END_IF;
ELSIF pop THEN
    IF top < 0 THEN
        error := TRUE;
        status := 16#8A05;
    ELSE
        minIndex := 0;
        minValue := stack[0];
        i := 1;
        WHILE i <= top DO
            IF stack[i] < minValue THEN
                minValue := stack[i];
                minIndex := i;
            END_IF;
            i := i + 1;
        END_WHILE;
        item := minValue;
        j := minIndex;
        WHILE j < top DO
            stack[j] := stack[j + 1];
            j := j + 1;
        END_WHILE;
        top := top - 1;
        error := FALSE;
        status := 16#0000;
    END_IF;
ELSE
    error := FALSE;
    status := 16#0000;
END_IF;

END_FUNCTION_BLOCK;