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

// Main logic
IF stop THEN
    // Stop has highest priority: stop all pumps
    FOR i := 1 TO 5 DO
        RunComds[i] := FALSE;
    END_FOR;
ELSIF start THEN
    IF NOT mode THEN
        // Manual mode: set run commands based on manual selections
        FOR i := 1 TO 5 DO
            RunComds[i] := selections[i];
        END_FOR;
    ELSE
        // Automatic mode: find and run 3 pumps with highest priorities
        // Initialize arrays
        FOR i := 1 TO 5 DO
            usedInAuto[i] := FALSE;
            RunComds[i] := FALSE;
        END_FOR;
        
        // Find 3 highest priority pumps
        runCount := 0;
        WHILE runCount < 3 DO
            maxPriority := -32768; // Minimum INT value
            maxIndex := 0;
            
            // Find highest priority pump not already selected
            FOR i := 1 TO 5 DO
                IF (priorities[i] > maxPriority) AND NOT usedInAuto[i] THEN
                    maxPriority := priorities[i];
                    maxIndex := i;
                END_IF;
            END_FOR;
            
            // Activate the found pump
            IF maxIndex > 0 THEN
                RunComds[maxIndex] := TRUE;
                usedInAuto[maxIndex] := TRUE;
                runCount := runCount + 1;
            ELSE
                // No more pumps available (should not happen with 5 pumps)
                EXIT;
            END_IF;
        END_WHILE;
    END_IF;
ELSE
    // When start is FALSE, maintain current state
    // No action needed - RunComds retain their previous values
END_IF;

END_FUNCTION_BLOCK