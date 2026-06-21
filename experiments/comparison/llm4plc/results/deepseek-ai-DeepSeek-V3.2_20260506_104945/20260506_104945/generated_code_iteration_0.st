START_ST
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
    currentState : INT := 0;
    minIndex : INT;
    minValue : INT;
    i : INT;
END_VAR

CASE currentState OF
    0: (* IDLE *)
        error := FALSE;
        status := 16#0000;
        IF reset THEN
            currentState := 1;
        ELSIF push THEN
            currentState := 2;
        ELSIF pop THEN
            currentState := 3;
        END_IF;
        
    1: (* RESET *)
        top := -1;
        error := FALSE;
        status := 16#0000;
        currentState := 0;
        
    2: (* PUSH *)
        IF top >= 3 THEN
            error := TRUE;
            status := 16#8A04;
        ELSE
            top := top + 1;
            stack[top] := item;
            error := FALSE;
            status := 16#0000;
        END_IF;
        currentState := 0;
        
    3: (* POP_MIN *)
        IF top < 0 THEN
            error := TRUE;
            status := 16#8A05;
        ELSE
            minIndex := 0;
            minValue := stack[0];
            FOR i := 1 TO top DO
                IF stack[i] < minValue THEN
                    minValue := stack[i];
                    minIndex := i;
                END_IF;
            END_FOR;
            item := minValue;
            FOR i := minIndex TO top - 1 DO
                stack[i] := stack[i + 1];
            END_FOR;
            top := top - 1;
            error := FALSE;
            status := 16#0000;
        END_IF;
        currentState := 0;
        
END_CASE;

END_FUNCTION_BLOCK
END_ST