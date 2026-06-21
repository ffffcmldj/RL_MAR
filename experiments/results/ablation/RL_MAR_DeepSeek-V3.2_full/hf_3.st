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
END_VAR

IF stop THEN
    FOR i := 1 TO 5 DO
        RunComds[i] := FALSE;
    END_FOR;
ELSE
    IF start THEN
        IF NOT mode THEN
            FOR i := 1 TO 5 DO
                RunComds[i] := selections[i];
            END_FOR;
        ELSE
            FOR i := 1 TO 5 DO
                usedInAuto[i] := FALSE;
                RunComds[i] := FALSE;
            END_FOR;
            runCount := 0;
            WHILE runCount < 3 DO
                maxPriority := -32768;
                maxIndex := 0;
                FOR i := 1 TO 5 DO
                    IF (priorities[i] > maxPriority) AND NOT usedInAuto[i] THEN
                        maxPriority := priorities[i];
                        maxIndex := i;
                    END_IF;
                END_FOR;
                IF maxIndex > 0 THEN
                    usedInAuto[maxIndex] := TRUE;
                    RunComds[maxIndex] := TRUE;
                    runCount := runCount + 1;
                ELSE
                    EXIT;
                END_IF;
            END_WHILE;
        END_IF;
    ELSE
        FOR i := 1 TO 5 DO
            RunComds[i] := FALSE;
        END_FOR;
    END_IF;
END_IF;

END_FUNCTION_BLOCK;