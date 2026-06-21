ructured-text
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

// State Management
IF stop THEN
    // STATE 3: STOP ALL PUMPS
    RunComds[1] := FALSE;
    RunComds[2] := FALSE;
    RunComds[3] := FALSE;
    RunComds[4] := FALSE;
    RunComds[5] := FALSE;
ELSE
    IF mode = FALSE AND start THEN
        // STATE 1: MANUAL MODE
        FOR i := 1 TO 5 DO
            RunComds[i] := selections[i];
        END_FOR
    ELSIF mode = TRUE AND start THEN
        // STATE 2: AUTOMATIC MODE
        // Initialize usedInAuto and runCount
        FOR i := 1 TO 5 DO
            usedInAuto[i] := FALSE;
        END_FOR
        runCount := 0;

        // Find the top 3 pumps based on priorities
        FOR j := 1 TO 3 DO
            maxPriority := -1;
            maxIndex := 0;
            FOR i := 1 TO 5 DO
                IF NOT usedInAuto[i] AND priorities[i] > maxPriority THEN
                    maxPriority := priorities[i];
                    maxIndex := i;
                END_IF
            END_FOR
            IF maxIndex > 0 THEN
                RunComds[maxIndex] := TRUE;
                usedInAuto[maxIndex] := TRUE;
                runCount := runCount + 1;
            END_IF
        END_FOR

        // Set remaining pumps to FALSE
        FOR i := 1 TO 5 DO
            IF NOT usedInAuto[i] THEN
                RunComds[i] := FALSE;
            END_IF
        END_FOR
    END_IF
END_IF

END_FUNCTION_BLOCK