START_ST
FUNCTION_BLOCK FB_Sum
VAR_INPUT
    maxValue : INT;
    execute : BOOL;
END_VAR
VAR_OUTPUT
    wData : WORD;
    done : BOOL;
END_VAR
VAR
    state : INT;
    prevExecute : BOOL;
    II : INT;
    tempSum : UINT;
END_VAR

CASE state OF
    0: (* IDLE *)
        done := FALSE;
        II := 0;
        tempSum := 0;

        IF (execute = TRUE) AND (prevExecute = FALSE) THEN
            state := 1;
        END_IF;

    1: (* SUMMING *)
        IF II <= maxValue THEN
            tempSum := tempSum + UINT(II);
            II := II + 1;
        ELSE
            state := 2;
        END_IF;

    2: (* DONE *)
        wData := WORD(tempSum);
        done := TRUE;
        II := 0;

        IF execute = FALSE THEN
            state := 0;
        END_IF;
END_CASE;

prevExecute := execute;
END_FUNCTION_BLOCK
END_ST