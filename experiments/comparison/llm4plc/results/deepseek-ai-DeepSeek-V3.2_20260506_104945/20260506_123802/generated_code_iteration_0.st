START_ST
FUNCTION_BLOCK FB_Fibonacci_Calculator
VAR_INPUT
    N : DINT := 5;
END_VAR
VAR_OUTPUT
    O : DINT := 1;
END_VAR
VAR
    state : INT := 0;
    prevState : INT := -1;
    F1 : DINT := 1;
    F2 : DINT := 1;
    CNT : DINT := 2;
    maxInt : DINT := 32767;
    temp : DINT;
END_VAR

CASE state OF
    0: (* STATE 0: INITIALIZE *)
        F1 := 1;
        F2 := 1;
        CNT := 2;
        O := 1;
        
        IF N > 2 THEN
            state := 1;
        ELSE
            state := 2;
        END_IF;
        
    1: (* STATE 1: CALCULATE NEXT FIBONACCI *)
        temp := F1 + F2;
        IF temp > maxInt THEN
            temp := maxInt;
        END_IF;
        
        F1 := F2;
        F2 := temp;
        CNT := CNT + 1;
        O := F2;
        
        IF CNT >= N THEN
            state := 2;
        ELSE
            state := 1;
        END_IF;
        
    2: (* STATE 2: FINISHED *)
        (* Maintain final O value, no state change *)
        state := 2;
        
END_CASE;

END_FUNCTION_BLOCK
END_ST