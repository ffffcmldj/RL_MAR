START_ST
FUNCTION_BLOCK FB_FactorialCalculator
VAR_INPUT
    X : INT;
END_VAR

VAR_OUTPUT
    FactorialResult : INT;
    FactorialGoodResult : INT;
END_VAR

VAR
    state : INT;
    prevState : INT;
    X_local : INT;
    tempResult : INT;
    overflowFlag : BOOL;
END_VAR

CASE state OF
    0: (* STATE 0: INITIALIZE *)
        FactorialResult := 0;
        FactorialGoodResult := 0;
        overflowFlag := FALSE;
        prevState := state;
        state := 1;
        
    1: (* STATE 1: CHECK_INPUT_RANGE *)
        X_local := X;
        IF (X_local >= -3) AND (X_local <= 3) THEN
            prevState := state;
            state := 2;
        ELSE
            prevState := state;
            state := 4;
        END_IF;
        
    2: (* STATE 2: COMPUTE_FACTORIALGOODRESULT *)
        tempResult := X_local;
        IF (tempResult > 32767) OR (tempResult < -32768) THEN
            overflowFlag := TRUE;
        END_IF;
        tempResult := tempResult * X_local;
        IF (tempResult > 32767) OR (tempResult < -32768) THEN
            overflowFlag := TRUE;
        END_IF;
        tempResult := tempResult * X_local;
        IF (tempResult > 32767) OR (tempResult < -32768) THEN
            overflowFlag := TRUE;
        END_IF;
        tempResult := tempResult * X_local;
        IF (tempResult > 32767) OR (tempResult < -32768) THEN
            overflowFlag := TRUE;
        END_IF;
        
        IF overflowFlag THEN
            overflowFlag := FALSE;
            prevState := state;
            state := 4;
        ELSE
            FactorialGoodResult := tempResult;
            prevState := state;
            state := 3;
        END_IF;
        
    3: (* STATE 3: COMPUTE_FACTORIALRESULT *)
        IF FactorialGoodResult > 1 THEN
            tempResult := FactorialGoodResult - 1;
            IF (tempResult > 32767) OR (tempResult < -32768) THEN
                overflowFlag := TRUE;
            END_IF;
            tempResult := FactorialGoodResult * tempResult;
            IF (tempResult > 32767) OR (tempResult < -32768) THEN
                overflowFlag := TRUE;
            END_IF;
            
            IF overflowFlag THEN
                overflowFlag := FALSE;
                prevState := state;
                state := 4;
            ELSE
                FactorialResult := tempResult;
                prevState := state;
                state := 1;
            END_IF;
        ELSE
            FactorialResult := FactorialGoodResult;
            prevState := state;
            state := 1;
        END_IF;
        
    4: (* STATE 4: HANDLE_INVALID_INPUT *)
        FactorialResult := 1;
        FactorialGoodResult := 0;
        prevState := state;
        state := 1;
        
END_CASE;
END_FUNCTION_BLOCK
END_ST