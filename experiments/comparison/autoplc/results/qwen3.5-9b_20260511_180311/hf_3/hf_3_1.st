FUNCTION_BLOCK MultiPumpCtrl
VAR_INPUT
    mode : BOOL;
    start : BOOL;
    stop : BOOL;
    priorities : ARRAY[1..5] OF INT;
    selections : ARRAY[1..5] OF BOOL;
END_VAR
VAR_OUTPUT
    RunComds : ARRAY[1..5] OF BOOL;
END_VAR
VAR
    i : INT;
    j : INT;
    maxPriority : INT;
    maxIndex : INT;
    runCount : INT;
    usedInAuto : ARRAY[1..5] OF BOOL;
    tempPriority : INT;
    tempIndex : INT;
END_VAR

FOR i := 1 TO 5 DO
    usedInAuto[i] := FALSE;
END_FOR

runCount := 0;
maxPriority := -9999;
maxIndex := 0;

IF mode = TRUE AND start = TRUE THEN
    FOR i := 1 TO 5 DO
        IF priorities[i] > maxPriority THEN
            maxPriority := priorities[i];
            maxIndex := i;
            usedInAuto[maxIndex] := TRUE;
            runCount := runCount + 1;
        END_IF;
    END_FOR;

    FOR i := 1 TO 5 DO
        IF usedInAuto[i] = TRUE THEN
            runCount := runCount + 1;
        END_IF;
    END_FOR;

    IF runCount < 3 THEN
        FOR i := 1 TO 5 DO
            IF priorities[i] = maxPriority AND usedInAuto[i] = FALSE THEN
                usedInAuto[i] := TRUE;
                runCount := runCount + 1;
            END_IF;
        END_FOR;
    END_IF;

    FOR i := 1 TO 5 DO
        IF usedInAuto[i] = TRUE THEN
            RunComds[i] := TRUE;
        ELSE
            RunComds[i] := FALSE;
        END_IF;
    END_FOR;

ELSIF mode = FALSE AND start = TRUE THEN
    FOR i := 1 TO 5 DO
        RunComds[i] := selections[i];
    END_FOR;

ELSE
    FOR i := 1 TO 5 DO
        RunComds[i] := FALSE;
    END_FOR;
END_IF;

IF stop = TRUE THEN
    FOR i := 1 TO 5 DO
        RunComds[i] := FALSE;
    END_FOR;
END_IF;

END_FUNCTION_BLOCK