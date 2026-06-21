START_ST
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
    k : INT;
    tempPriority : INT;
    tempIndex : INT;
    usedInAuto : ARRAY[1..5] OF BOOL;
    runCount : INT;
    maxPriority : INT;
    maxIndex : INT;
    state : INT; // 0: STOPPED, 1: MANUAL_MODE, 2: AUTO_MODE
    stopActive : BOOL;
END_VAR

// Initialize state on first execution or if stop is active
IF NOT stopActive THEN
    IF stop THEN
        state := 0;
        stopActive := TRUE;
    END_IF;
END_IF;

// Determine current state based on inputs
// State 0: STOPPED (Stop active OR Start inactive)
// State 1: MANUAL_MODE (Mode FALSE, Start TRUE, Stop FALSE)
// State 2: AUTO_MODE (Mode TRUE, Start TRUE, Stop FALSE)

IF stop THEN
    state := 0;
    stopActive := TRUE;
ELSIF NOT start THEN
    state := 0;
    stopActive := FALSE;
ELSIF mode = FALSE THEN
    state := 1;
    stopActive := FALSE;
ELSIF mode = TRUE THEN
    state := 2;
    stopActive := FALSE;
END_IF;

// Reset RunComds array
FOR i := 1 TO 5 DO
    RunComds[i] := FALSE;
END_FOR;

// Execute logic based on state
CASE state OF
    0: // STOPPED STATE
        // All pumps stopped
        // RunComds remains all FALSE (already initialized above)
        ;

    1: // MANUAL_MODE
        // RunComds[i] = selections[i]
        FOR i := 1 TO 5 DO
            RunComds[i] := selections[i];
        END_FOR;

    2: // AUTO_MODE
        // Find 3 pumps with highest priorities
        // Reset usedInAuto and runCount
        runCount := 0;
        FOR i := 1 TO 5 DO
            usedInAuto[i] := FALSE;
        END_FOR;

        // Sort logic: Find top 3 priorities
        // We will perform a selection sort to find the top 3 indices
        // Loop to find the 1st highest
        FOR k := 1 TO 3 DO
            maxPriority := -9999; // Lower than any possible INT
            maxIndex := 0;
            
            // Scan all pumps to find the one with max priority not yet used
            FOR i := 1 TO 5 DO
                IF NOT usedInAuto[i] THEN
                    IF priorities[i] > maxPriority THEN
                        maxPriority := priorities[i];
                        maxIndex := i;
                    END_IF;
                END_IF;
            END_FOR;
            
            // Mark the found pump as used and set command
            IF maxIndex > 0 THEN
                usedInAuto[maxIndex] := TRUE;
                RunComds[maxIndex] := TRUE;
                runCount := runCount + 1;
            END_IF;
        END_FOR;
        
        // Ensure remaining pumps are FALSE (already done by initialization, but explicit for clarity)
        FOR i := 1 TO 5 DO
            IF NOT usedInAuto[i] THEN
                RunComds[i] := FALSE;
            END_IF;
        END_FOR;
END_CASE;

END_FUNCTION_BLOCK
END_ST