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

// Step 1: Stop Signal Processing (Highest Priority)
IF stop THEN
    // Set all pumps to stop
    FOR i := 1 TO 5 DO
        RunComds[i] := FALSE;
    END_FOR;
ELSE
    // Step 2: Start Signal and Mode Evaluation
    IF start THEN
        // Manual Mode
        IF NOT mode THEN
            FOR i := 1 TO 5 DO
                RunComds[i] := selections[i];
            END_FOR;
        // Automatic Mode
        ELSE
            // Initialize usedInAuto array
            FOR i := 1 TO 5 DO
                usedInAuto[i] := FALSE;
            END_FOR;
            
            // Initialize runCount
            runCount := 0;
            
            // Find 3 pumps with highest priorities
            WHILE runCount < 3 DO
                maxPriority := -32768;  // Minimum INT value
                maxIndex := 0;
                
                // Find the highest priority pump not yet selected
                FOR i := 1 TO 5 DO
                    IF NOT usedInAuto[i] AND priorities[i] > maxPriority THEN
                        maxPriority := priorities[i];
                        maxIndex := i;
                    END_IF;
                END_FOR;
                
                // If a pump was found, select it
                IF maxIndex > 0 THEN
                    usedInAuto[maxIndex] := TRUE;
                    RunComds[maxIndex] := TRUE;
                    runCount := runCount + 1;
                ELSE
                    // No more pumps available, break the loop
                    EXIT;
                END_IF;
            END_WHILE;
            
            // Set remaining pumps to FALSE
            FOR i := 1 TO 5 DO
                IF NOT usedInAuto[i] THEN
                    RunComds[i] := FALSE;
                END_IF;
            END_FOR;
        END_IF;
    END_IF;
    // Step 3: If stop = FALSE and start = FALSE, maintain current RunComds values
END_IF;

END_FUNCTION_BLOCK