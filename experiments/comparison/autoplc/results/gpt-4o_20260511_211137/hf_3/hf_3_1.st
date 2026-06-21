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

// Initialization
FOR i := 1 TO 5 DO
    RunComds[i] := FALSE;
    usedInAuto[i] := FALSE;
END_FOR

// Stop Condition Handling
IF stop THEN
    FOR i := 1 TO 5 DO
        RunComds[i] := FALSE;
    END_FOR
ELSE
    // Manual Mode Operation
    IF NOT mode AND start THEN
        FOR i := 1 TO 5 DO
            RunComds[i] := selections[i];
        END_FOR
    END_IF

    // Automatic Mode Operation
    IF mode AND start THEN
        runCount := 0;
        WHILE runCount < 3 DO
            maxPriority := -1;
            maxIndex := -1;
            FOR i := 1 TO 5 DO
                IF NOT usedInAuto[i] AND (priorities[i] > maxPriority) THEN
                    maxPriority := priorities[i];
                    maxIndex := i;
                END_IF
            END_FOR
            IF maxIndex <> -1 THEN
                RunComds[maxIndex] := TRUE;
                usedInAuto[maxIndex] := TRUE;
                runCount := runCount + 1;
            END_IF
        END_WHILE
    END_IF
END_IF

END_FUNCTION_BLOCK