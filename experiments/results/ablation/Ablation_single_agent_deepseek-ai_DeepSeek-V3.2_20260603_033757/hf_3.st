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
    sortedPriorities : ARRAY[1..5] OF INT;
    sortedIndices : ARRAY[1..5] OF INT;
END_VAR

// Main logic
IF stop THEN
    // Stop has highest priority - stop all pumps
    FOR i := 1 TO 5 DO
        RunComds[i] := FALSE;
    END_FOR;
ELSE
    // Initialize arrays
    FOR i := 1 TO 5 DO
        RunComds[i] := FALSE;
        usedInAuto[i] := FALSE;
        sortedIndices[i] := i;
        sortedPriorities[i] := priorities[i];
    END_FOR;
    
    // Simple bubble sort to sort pumps by priority (descending)
    FOR i := 1 TO 4 DO
        FOR j := i + 1 TO 5 DO
            IF sortedPriorities[i] < sortedPriorities[j] THEN
                // Swap priorities
                tempPriority := sortedPriorities[i];
                sortedPriorities[i] := sortedPriorities[j];
                sortedPriorities[j] := tempPriority;
                
                // Swap indices to track which pump
                tempIndex := sortedIndices[i];
                sortedIndices[i] := sortedIndices[j];
                sortedIndices[j] := tempIndex;
            END_IF;
        END_FOR;
    END_FOR;
    
    IF start THEN
        IF NOT mode THEN
            // Manual mode: use selections array directly
            FOR i := 1 TO 5 DO
                RunComds[i] := selections[i];
            END_FOR;
        ELSE
            // Automatic mode: run 3 pumps with highest priorities
            runCount := 0;
            FOR i := 1 TO 5 DO
                IF runCount < 3 THEN
                    RunComds[sortedIndices[i]] := TRUE;
                    runCount := runCount + 1;
                ELSE
                    RunComds[sortedIndices[i]] := FALSE;
                END_IF;
            END_FOR;
        END_IF;
    END_IF;
END_IF;

END_FUNCTION_BLOCK